# frozen_string_literal: true

module BloodContracts
  module Instrumentation
    # Class that configures the instrumentation for refinement types matching
    class Config
      # Map of instrument classes where the key is the matching pattern
      #
      # @return [Hash<Regexp, Instrument>]
      #
      attr_reader :instruments

      # List of refinement types defined in the app
      #
      # @return [Array<BC::Refined>]
      #
      attr_reader :types

      # Pool size of finalizer instance
      #
      # @return [Integer]
      #
      attr_reader :finalizer_pool_size

      # Type of finalizer instance
      #
      # @return [Symbol]
      #
      attr_reader :session_finalizer

      # Initialize the config with default values
      # Also inits the SessionFinalizer
      def initialize
        @instruments = {}
        @types = []
        @finalizer_pool_size = SessionFinalizer::DEFAULT_POOL_SIZE
        @session_finalizer = :basic
        reset_session_finalizer!
      end

      # Set the pool size for SessionFinalizer (make sense only for
      # SessionFinalizer::Fibers right now)
      #
      # @param value [Integer] size of finalizer fibers pool
      # @return [Integer]
      #
      def finalizer_pool_size=(value)
        @finalizer_pool_size = Integer(value).tap { reset_session_finalizer! }
      end

      # Set the type of SessionFinalizer for instrumentation
      # See SessionFinalizer::Basic, SessionFinalizer::Threads and
      # SessionFinalizer::Fibers
      #
      # @param value [Symbol] name of SessionFinalizer, could be one of
      #   :basic, :threads, :fibers
      # @return [Symbol]
      #
      def session_finalizer=(value)
        @session_finalizer = value.tap { reset_session_finalizer! }
      end

      # Main setting in the config
      # Define an instument for Refinement Types, applies only to types
      # matched by the pattern by type class name
      #
      # @param pattern [String, Regexp] defines which types to apply this
      #   instrument
      # @param processor [Proc, #call] defines the processor for insturmentation
      #   session, during the finalize phase the processor#call method would be
      #   called with Session instance as a parameter
      #
      # @option before [Proc, #call] defines a method that is called right
      #   after Session#start inside matching process of the refinement type
      # @option after [Proc, #call] defines a method that is called right
      #   after Session#finish inside matching process of the refinement type
      #
      # @return [Nothing]
      #
      def instrument(pattern, processor, **kwargs)
        pattern = /#{pattern}/i unless pattern.is_a?(Regexp)

        @instruments[pattern] = Instrument.build(processor, **kwargs)
        reset_cache!(pattern)
      end

      # @private
      # Select only instruments matching the type_name
      protected def select_instruments(type_name)
        @instruments.select { |pattern, _| type_name =~ /#{pattern}/i }.values
      end

      # @private
      # Reset instruments cache for refinement types that match filter
      protected def reset_cache!(filter = nil)
        filter = /#{filter}/i unless filter.is_a?(Regexp)

        types.each { |type| type.reset_instruments! if type.name =~ filter }
      end

      # @private
      # Reset session finalizer instance using current config
      protected def reset_session_finalizer!
        SessionFinalizer.init(session_finalizer, pool_size: finalizer_pool_size)
      end
    end
  end
end
