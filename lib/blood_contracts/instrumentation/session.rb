# frozen_string_literal: true

module BloodContracts
  module Instrumentation
    # Basic class to hold data about matching process
    # Start date, finish date, result type name and the validation context
    class Session
      # Unique ID of the session
      #
      # @return [String]
      #
      attr_reader :id

      # Time when session started
      #
      # @return [Time]
      #
      attr_reader :started_at

      # Time when session finished
      #
      # @return [Time]
      #
      attr_reader :finished_at

      # Frozen hash of matching pipeline context
      #
      # @return [Hash]
      #
      attr_reader :context

      # Additional text about scope of the mathc (e.g. "User:12")
      #
      # @return [String]
      #
      attr_reader :scope

      # Name of the type which owns the session
      #
      # @return [String]
      #
      attr_reader :matcher_type_name

      # Name of the matching result type
      #
      # @return [String]
      #
      attr_reader :result_type_name

      # List of matches in the pipeline run
      #
      # @return [Array<String>]
      #
      attr_reader :path

      # Additional data for instrumentaion stores here
      #
      # @return [Hash]
      #
      attr_reader :extras

      # Whether the result was valid or not
      #
      # @return [Boolean]
      #
      def valid?
        !!@valid
      end

      # Initialize the session with matcher type name with defaults
      #
      # @param type_name [String] name of the type which owns the session
      #
      # @return [Nothing]
      #
      def initialize(type_name)
        @id = SecureRandom.hex(10)
        @matcher_type_name = type_name
        @extras = {}
        @context = {}
      end

      # Marks the session as started
      # If you inherit the Session this method runs right BEFORE matching start
      #
      # @return [Nothing]
      #
      def start
        @started_at = Time.now
      end

      # Session scope fallback
      NO_SCOPE = "unscoped"

      # Session validation path fallback
      NO_VALIDATION_PATH = "undefined"

      # Session result type name fallback
      NO_TYPE_MATCH = "unmatched"

      # Marks the session as finished (with the type)
      # If you inherit the Session this method runs right AFTER matching
      # finished (even if an exception raised the method would be called)
      #
      # @param type_match [BC::Refined] result type of matching pipeline
      #
      # @return [Nothing]
      #
      def finish(type_match)
        @finished_at = Time.now
        @context = type_match.context.dup.freeze if type_match
        @valid = type_match&.valid?

        @result_type_name = type_match&.class&.name || NO_TYPE_MATCH
        @id =    @context.fetch(:session_id) { @id }
        @scope = @context.fetch(:scope) { NO_SCOPE }
        @path =  @context.fetch(:steps) { NO_VALIDATION_PATH }
      end
    end
  end
end
