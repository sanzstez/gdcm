require "tempfile"

module GDCM
  # @private
  module Utilities

    module_function

    ##
    # Cross-platform way of finding an executable in the $PATH.
    #
    # @example
    #   GDCM::Utilities.which('ruby') #=> "/usr/bin/ruby"
    #
    def which(cmd)
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
      ENV.fetch('PATH').split(File::PATH_SEPARATOR).each do |path|
        exts.each do |ext|
          exe = File.join(path, "#{cmd}#{ext}")
          return exe if File.executable? exe
        end
      end
      nil
    end

    def tempfile(extension)
      Tempfile.new(["gdcm", extension]).tap do |tempfile|
        tempfile.binmode
        yield tempfile if block_given?
        tempfile.close
      end
    end

  end
end
