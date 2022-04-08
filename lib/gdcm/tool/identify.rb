module GDCM
  class Tool
    class Identify < GDCM::Tool
      def initialize(*args)
        super("gdcminfo", *args)
      end
    end
  end
end
