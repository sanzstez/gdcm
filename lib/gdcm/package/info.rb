module GDCM
  class Package
    class Info
      attr_reader :base

      def initialize base
        @base = base
      end

      def raw
        dump.lines.each_with_object([]) do |line, memo|
          case line
          when /^\s*\((?<package>[0-9a-f]{4},[0-9a-f]{4})\)/
            puts line
          end
        end
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

      def meta= value
        @meta = value
      end

      def dump
        GDCM::Tool::Dump.new do |builder|
          yield builder if block_given?
          builder << base.path
        end
      end

      def identify
        GDCM::Tool::Identify.new do |builder|
          yield builder if block_given?
          builder << base.path
        end
      end
    end
  end
end
