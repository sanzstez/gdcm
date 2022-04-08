require 'tempfile'
require 'stringio'
require 'pathname'

require 'gdcm/utilities'

module GDCM
  class Image

    ##
    # This is the primary loading method used by all of the other class
    # methods.
    #
    # Use this to pass in a stream object. Must respond to #read(size) or be a
    # binary string object (BLOB)
    #
    # @param stream [#read, String] Some kind of stream object that needs
    #   to be read or is a binary String blob
    # @param ext [String] A manual extension to use for reading the file. Not
    #   required, but if you are having issues, give this a try.
    # @return [GDCM::Image]
    #
    def self.read(stream, ext = nil)
      if stream.is_a?(String)
        stream = StringIO.new(stream)
      end

      create(ext) { |file| IO.copy_stream(stream, file) }
    end

    ##
    # Opens a specific file either on the local file system.
    # Use this if you don't want to overwrite file.
    #
    # Extension is either guessed from the path or you can specify it as a
    # second parameter.
    #
    # @param path [String] Either a local file path
    # @param ext [String] Specify the extension you want to read it as
    # @param options [Hash] Specify options for the open method
    # @return [GDCM::Image] The loaded file
    #
    def self.open(path, ext = nil, options = {})
      options, ext = ext, nil if ext.is_a?(Hash)

      # Don't use Kernel#open, but reuse its logic
      openable =
        if path.respond_to?(:open)
          path
        else
          options = { binmode: true }.merge(options)
          Pathname(path)
        end

      ext ||= File.extname(openable.to_s)
      ext.sub!(/:.*/, '') # hack for filenames that include a colon

      openable.open(**options) { |file| read(file, ext) }
    end

    ##
    # Used to create a new file object data-copy.
    #
    # Takes an extension in a block and can be used to build a new file
    # object. Used by both {.open} and {.read} to create a new object. Ensures
    # we have a good tempfile.
    #
    # @param ext [String] Specify the extension you want to read it as
    # @param validate [Boolean] If false, skips validation of the created
    #   file. Defaults to true.
    # @yield [Tempfile] You can #write bits to this object to create the new
    #   file
    # @return [GDCM::Image] The created file
    #
    def self.create(ext = nil, validate = GDCM.validate_on_create, &block)
      tempfile = GDCM::Utilities.tempfile(ext.to_s.downcase, &block)

      new(tempfile.path, tempfile).tap do |file|
        file.validate! if validate
      end
    end

    attr_reader :path
    attr_reader :tempfile

    def initialize(input_path, tempfile = nil)
      @path = input_path.to_s
      @tempfile = tempfile
    end

    def to_blob
      File.binread(path)
    end

    def valid?
      validate!
      true
    rescue GDCM::Invalid
      false
    end

    def validate!
      identify
    rescue GDCM::Error => error
      raise GDCM::Invalid, error.message
    end

    def identify
      GDCM::Tool::Identify.new do |builder|
        yield builder if block_given?
        builder << path
      end
    end

    def convert(read_opts={})
      if @tempfile
        new_tempfile = GDCM::Utilities.tempfile(".dcm")
        new_path = new_tempfile.path
      else
        new_path = Pathname(path).sub_ext(".dcm").to_s
      end

      input_path = path.dup

      GDCM::Tool::Convert.new do |convert|
        read_opts.each do |opt, val|
          convert.send(opt.to_s, val)
        end

        yield convert if block_given?
        convert << input_path
        convert << new_path
      end

      if @tempfile
        destroy!
        @tempfile = new_tempfile
      else
        File.delete(path) unless path == new_path
      end

      path.replace new_path

      self
    end

    ##
    # Writes the temporary file out to either a file location (by passing in a
    # String) or by passing in a Stream that you can #write(chunk) to
    # repeatedly
    #
    # @param output_to [String, Pathname, #read] Some kind of stream object
    #   that needs to be read or a file path as a String
    #
    def write(output_to)
      case output_to
      when String, Pathname
        FileUtils.copy_file path, output_to unless path == output_to.to_s
      else
        IO.copy_stream File.open(path, "rb"), output_to
      end
    end

    ##
    # Destroys the tempfile (created by {.open}) if it exists.
    #
    def destroy!
      if @tempfile
        FileUtils.rm_f @tempfile.path.sub(/mpc$/, "cache") if @tempfile.path.end_with?(".mpc")
        @tempfile.unlink
      end
    end
  end
end
