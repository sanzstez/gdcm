require "gdcm/shell"

module GDCM
  ##
  # Abstract class that wraps command-line tools. It shouldn't be used directly,
  # but through one of its subclasses. Use
  # this class if you want to be closer to the metal and execute GDCM
  # commands directly, but still with a nice Ruby interface.
  #
  class Tool
    ##
    # Aside from classic instantiation, it also accepts a block, and then
    # executes the command in the end.
    #
    # @example
    #   version = GDCM::Tool::Identify.new { |b| b.version }
    #   puts version
    #
    # @return [GDCM::Tool, String] If no block is given, returns an
    #   instance of the tool, if block is given, returns the output of the
    #   command.
    #
    def self.new(*args)
      instance = super(*args)

      if block_given?
        yield instance
        instance.call
      else
        instance
      end
    end

    # @private
    attr_reader :name, :args

    # @param name [String]
    # @param options [Hash]
    # @option options [Boolean] :whiny Whether to raise errors on non-zero
    #   exit codes.
    # @example
    #   GDCM::Tool::Identify.new(whiny: false) do |identify|
    #     identify.help # returns exit status 1, which would otherwise throw an error
    #   end
    def initialize(name, options = {})
      @name  = name
      @args  = []
      @whiny = options.is_a?(Hash) ? options.fetch(:whiny, GDCM.whiny) : options
    end

    ##
    # Executes the command that has been built up.
    #
    # @example
    #   convert = GDCM::Tool::Convert.new
    #   convert.resize("500x500")
    #   convert << "path/to/file.dcm"
    #   convert.call # executes `convert --resize 500x500 path/to/file.dcm`
    #
    # @example
    #   convert = GDCM::Tool::Convert.new
    #   # build the command
    #   convert.call do |stdout, stderr, status|
    #     # ...
    #   end
    #
    # @yield [Array] Optionally yields stdout, stderr, and exit status
    #
    # @return [String] Returns the output of the command
    #
    def call(*args)
      options = args[-1].is_a?(Hash) ? args.pop : {}
      whiny = args.fetch(0, @whiny)

      options[:whiny] = whiny
      options[:stderr] = false if block_given?

      shell = GDCM::Shell.new
      stdout, stderr, status = shell.run(command, options)
      yield stdout, stderr, status if block_given?

      stdout.chomp("\n")
    end

    ##
    # The currently built-up command.
    #
    # @return [Array<String>]
    #
    # @example
    #   convert = GDCM::Tool::Convert.new
    #   convert.resize "500x500"
    #   convert.contrast
    #   convert.command #=> ["convert", "--resize", "500x500", "--contrast"]
    #
    def command
      [*executable, *args]
    end

    def executable
      exe = [name]
      exe
    end

    ##
    # Appends raw options, useful for appending file paths.
    #
    # @return [self]
    #
    def <<(arg)
      args << arg.to_s
      self
    end

    ##
    # Merges a list of raw options.
    #
    # @return [self]
    #
    def merge!(new_args)
      new_args.each { |arg| self << arg }
      self
    end

    ##
    # Changes the last operator to its "plus" form.
    #
    # @example
    #   GDCM::Tool::Convert.new do |convert|
    #     convert.antialias.+
    #     convert.distort.+("Perspective", "0,0,4,5 89,0,45,46")
    #   end
    #   # executes `convert +antialias +distort Perspective '0,0,4,5 89,0,45,46'`
    #
    # @return [self]
    #
    def +(*values)
      args[-1] = args[-1].sub(/^-/, '+')
      self.merge!(values)
      self
    end

    ##
    # Create an GDCM stack in the command (surround.
    #
    # @example
    #   GDCM::Tool::Convert.new do |convert|
    #     convert << "1.dcm"
    #     convert.stack do |stack|
    #       stack << "2.dcm"
    #       stack.rotate(30)
    #     end
    #     convert.append.+
    #     convert << "3.dcm"
    #   end
    #   # executes `convert 1.dcm \( 2.dcm --rotate 30 \) +append 3.dcm`
    #
    def stack(*args)
      self << "("
      args.each do |value|
        case value
        when Hash   then value.each { |key, value| send(key, *value) }
        when String then self << value
        end
      end
      yield self if block_given?
      self << ")"
    end

    ##
    # Adds GDCM's pseudo-filename `-` for standard input.
    #
    # @example
    #   identify = GDCM::Tool::Identify.new
    #   identify.stdin
    #   identify.call(stdin: content)
    #   # executes `identify -` with the given standard input
    #
    def stdin
      self << "-"
    end

    ##
    # Adds GDCM's pseudo-filename `-` for standard output.
    #
    # @example
    #   content = GDCM::Tool::Convert.new do |convert|
    #     convert << "1.dcm"
    #     convert.auto_orient
    #     convert.stdout
    #   end
    #   # executes `convert 1.dcm --auto-orient -` which returns file contents
    #
    def stdout
      self << "-"
    end

    ##
    # Any undefined method will be transformed into a CLI option
    #
    # @example
    #   convert = GDCM::Tool.new("convert")
    #   convert.adaptive_blur("...")
    #   convert.foo_bar
    #   convert.command.join(" ") # => "convert --adaptive-blur ... --foo-bar"
    #
    def method_missing(name, *args)
      option = "--#{name.to_s.tr('_', '-')}"
      self << option
      self.merge!(args)
      self
    end
  end
end

require "gdcm/tool/convert"
require "gdcm/tool/identify"
