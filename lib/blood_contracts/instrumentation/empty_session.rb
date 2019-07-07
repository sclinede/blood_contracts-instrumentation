module BloodContracts
  module Instrumentation
    class EmptySession < Session
      def initialize; end
      def start(*); end
      def finish(*); end
      def publish!; end
    end
  end
end
