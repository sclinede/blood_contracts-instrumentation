# frozen_string_literal: true

module BloodContracts
  module Instrumentation
    # Wrapper for exception happend during the match instrumentation
    # Should not be used in the app, to distinguish between expected and
    # unexpected failures
    class FailedMatch < ::BC::ContractFailure
      # Initialize failure type with exception
      #
      # @param value [Exception] rescued exception from the type match
      # @option context [Hash] shared context of matching pipeline
      #
      # @return [FailedMatch]
      #
      def initialize(exception, context: {})
        @errors = []
        @context = context
        @value = exception
        @context[:exception] = exception
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
