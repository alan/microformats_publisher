module Microformats
  module Appenders
    module Arrays
      def <<(other); super(other) unless include?(other); end
    end

    module Hashs
      def <<(other); merge!(other); end
    end
  end
end