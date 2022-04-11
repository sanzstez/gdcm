module GDCM
  class Package
    class Info
      attr_reader :package_instance

      def initialize package_instance
        @package_instance = package_instance
      end

      def data
        if meta.respond_to?(:lines)
          meta.lines.each_with_object({}) do |line, memo|
            case line
            when /^MediaStorage is (?<media_storage>[\d.]+)/
              memo['MediaStorage'] = $~[:media_storage]
            when /^TransferSyntax is (?<transfer_syntax>[\d.]+)/
              memo['TransferSyntax'] = $~[:transfer_syntax]
            else
              key, _, value = line.partition(/:[\s]*/).map(&:strip)

              memo[key] = value
            end
          end
        end
      end

      def meta
        @meta ||= identify
      end

      def clear
        @meta = nil
      end

      def identify
        GDCM::Tool::Identify.new do |builder|
          yield builder if block_given?
          builder << package_instance.path
        end
      end
    end
  end
end
