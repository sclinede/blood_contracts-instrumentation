# frozen_string_literal: true

module BloodContracts
  module Instrumentation
    # Top-level interface for Instrument finalizers
    module SessionFinalizer
      module_function

      require_relative "./session_finalizer/basic.rb"
      require_relative "./session_finalizer/fibers.rb"
      require_relative "./session_finalizer/threads.rb"

      # Names of finalizers
      #
      # @return [Array<Symbol>]
      #
      FINALIZERS = %i[basic fibers threads].freeze

      # @private
      WRONG_FINALIZER_MSG = "Choose finalizer wisely: #{FINALIZERS.join(', ')}"

      # @private
      DEFAULT_POOL_SIZE = 13

      # Current thread instance of the Session finalizer
      #
      # @return [#finalize!]
      #
      def instance
        Thread.current[:bc_session_processor] ||=
          Instrumentation.reset_session_finalizer!
      end

      # Reset the finalizer by name
      #
      # @param name [Symbol] finalizer to find
      # @param **opts [Hash] options passed to finalizer constructor
      #
      # @return [#finalize!]
      #
      def init(name, **opts)
        Thread.current[:bc_session_finalizer] = find_finalizer_by(name, **opts)
      end

      # @private
      private def find_finalizer_by(name, pool_size: DEFAULT_POOL_SIZE)
        case name
        when :basic
          Basic
        when :fibers
          Fibers.new(pool_size)
        when :threads
          Threads
        else
          raise ArgumentError, WRONG_FINALIZER_MSG
        end
      end
    end
  end
end
