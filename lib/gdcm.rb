require 'gdcm/version'
require 'gdcm/configuration'

module GDCM

  extend GDCM::Configuration

  ##
  # Returns GDCM's version.
  #
  # @return [String]
  def self.cli_version
    output = GDCM::Tool::Identify.new(&:version)
    output[/\d+\.\d+\.\d+(-\d+)?/]
  end

  class Error < RuntimeError; end
  class Invalid < StandardError; end

end

require 'gdcm/tool'
require 'gdcm/image'
