module GDCM
  class Tool
    class Convert < GDCM::Tool
      def initialize(*args)
        super("gdcmconv", *args)
      end
    end
  end
end
