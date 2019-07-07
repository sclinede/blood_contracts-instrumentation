module BloodContracts
  module Instrumentation
    class FailedMatch < ::BC::ContractFailure;
      def initialize(value = nil, context: {}, **)
        @errors = []
        @context = context
        @value = value
        @context[:exception] = value
      end

      # Predicate, whether the data is valid or not
      # (for the ExceptionCaught it is always False)
      #
      # @return [Boolean]
      #
      def valid?
        false
      end

      # Reader for the exception caught
      #
      # @return [Exception]
      #
      def exception
        @context[:exception]
      end
    end
  end
end
