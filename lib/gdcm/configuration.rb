require 'gdcm/utilities'
require 'logger'

module GDCM
  module Configuration
    ##
    # If you don't want commands to take too long, you can set a timeout (in
    # seconds).
    #
    # @return [Integer]
    #
    attr_accessor :timeout
    ##
    # When get to `true`, it outputs each command to STDOUT in their shell
    # version.
    #
    # @return [Boolean]
    #
    attr_reader :debug
    ##
    # Logger for {#debug}, default is `GDCM::Logger.new(STDOUT)`, but
    # you can override it, for example if you want the logs to be written to
    # a file.
    #
    # @return [Logger]
    #
    attr_accessor :logger

    ##
    # If set to `true`, it will `identify` every newly created image, and raise
    # `MiniMagick::Invalid` if the image is not valid. Useful for validating
    # user input, although it adds a bit of overhead. Defaults to `true`.
    #
    # @return [Boolean]
    #
    attr_accessor :validate_on_create
    ##
    # If set to `true`, it will `identify` every image that gets written (with
    # {GDCM::Image#write}), and raise `GDCM::Invalid` if the image
    # is not valid. Useful for validating that processing was sucessful,
    # although it adds a bit of overhead. Defaults to `true`.
    #
    # @return [Boolean]

    #
    attr_accessor :whiny

    ##
    # Instructs GDCM how to execute the shell commands. Available
    # APIs are "open3" (default) and "posix-spawn" (requires the "posix-spawn"
    # gem).
    #
    # @return [String]
    #
    attr_accessor :shell_api

    def self.extended(base)
      base.validate_on_create = true
      base.whiny = true
      base.shell_api = "open3"
      base.logger = Logger.new($stdout).tap { |l| l.level = Logger::INFO }
    end

    ##
    # @yield [self]
    # @example
    #   GDCM.configure do |config|
    #     config.timeout = 5
    #   end
    #
    def configure
      yield self
    end
  end
end
