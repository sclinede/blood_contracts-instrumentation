require 'fiber'

module BloodContracts
  module Instrumentation
    module SessionFinalizer
      require_relative './session_finalizer/basic.rb'
      require_relative './session_finalizer/fibers.rb'
      require_relative './session_finalizer/threads.rb'

      FINALIZERS = %i(basic fibers threads)
      DEFAULT_POOL_SIZE = 13

      def instance
        Thread.current[:bc_session_processor] ||=
          Instrumentation.config.reset_session_finalizer!
      end
      module_function :instance

      def init(processor, pool_size: DEFAULT_POOL_SIZE)
        instance =
          case processor
          when :basic
            Basic
          when :fibers
            Fibers.new(pool_size)
          when :threads
            Threads
          else
            raise ArgumentError,
                  "Choose right finalizer (#{FINALIZERS.join(',')})"
          end

        Thread.current[:bc_session_finalizer] = instance
      end
      module_function :init
    end
  end
end
