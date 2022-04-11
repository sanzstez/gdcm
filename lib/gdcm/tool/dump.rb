module GDCM
  class Tool
    class Dump < GDCM::Tool
      def initialize(*args)
        super("gdcmdump", *args)
      end
    end
  end
end
