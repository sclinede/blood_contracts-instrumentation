module BloodContracts
  module Instrumentation
    class Config
      attr_reader :instruments, :types, :processor_pool_size, :session_finalizer
      def initialize
        @instruments = {}
        @types = []
        @processor_pool_size = SessionFinalizer::DEFAULT_POOL_SIZE
        @session_finalizer = :basic
        reset_session_finalizer!
      end

      def sessions_pool_size=(value)
        @instruments_pool_size = Integer(value).tap { reset_session_finalizer! }
      end

      def session_finalizer=(value)
        @session_finalizer = value.tap { reset_session_finalizer! }
      end

      def instrument(pattern, processor, **kwargs)
        pattern = /#{pattern}/i unless pattern.is_a?(Regexp)

        @instruments[pattern] = Instrument.build(processor, **kwargs)
        reset_cache!(pattern)
      end

      def select_instruments(type_name)
        @instruments.select { |pattern, _| type_name =~ /#{pattern}/i }.values
      end

      def reset_cache!(filter = nil)
        filter = /#{filter}/i unless filter.is_a?(Regexp)

        types.each { |type| type.reset_instruments! if type.name =~ filter }
      end

      def reset_session_finalizer!
        SessionFinalizer.init(session_finalizer, pool_size: processor_pool_size)
      end
    end
  end
end
