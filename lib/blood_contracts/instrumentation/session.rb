module BloodContracts
  module Instrumentation
    class Session
      class << self
        alias session new
      end

      attr_reader :session_id, :started_at, :context, :scope, :name, :path,
                  :instruments, :extras
      def initialize
        @session_id = SecureRandom.hex(10)
        @extras = {}
      end

      def start(name)
        @name = name
        @started_at = Time.now
      end

      NO_SCOPE = "unscoped".freeze
      NO_VALIDATION_PATH = "undefined".freeze

      def finish(type_match)
        @context = type_match.context.dup.freeze if type_match
        @context ||= {}
        @scope = @context.fetch(:scope) { NO_SCOPE }
        @path = @context.fetch(:steps) { NO_VALIDATION_PATH }
      end
    end
  end
end
