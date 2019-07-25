# frozen_string_literal: true

module BloodContracts
  module Instrumentation
    # Base class for instrumentation tooling
    class Instrument
      class << self
        # Builds an Instrument class from the proto and before/after callbacks
        #
        # When `proto` is just a Proc - we create new Instrument class around
        # Otherwise - use the `proto` object as an instrument
        #
        # Also if before/after is defined we add the definition to the `proto`
        #
        # @param proto [#call, Proc] callable object that is used as an
        #   instrumentation tool
        # @option before [#call, Proc] definition of before callback, it runs
        #   right after Session#start in the matching pipeline, the argument
        #   is Session instance for current BC::Refined#match call
        # @option before [#call, Proc] definition of before callback, it runs
        #   right after Session#finish in the matching pipeline, the argument
        #   is Session instance for current BC::Refined#match call
        #
        # @return [Instrument, #call]
        #
        def build(proto, before: nil, after: nil)
          raise ArgumentError unless proto.respond_to?(:call)

          instance = instrument_from_proc(proto)

          if before.respond_to?(:call)
            instance.define_singleton_method(:before, &before)
          end

          define_stub(instance, :before)

          if after.respond_to?(:call)
            instance.define_singleton_method(:after, &after)
          end

          define_stub(instance, :after)

          instance
        end

        private def define_stub(instance, name)
          return if instance.respond_to?(name)

          instance.define_singleton_method(name) { |_| }
        end

        # @private
        private def instrument_from_proc(proto)
          return proto unless proto.is_a?(Proc)

          inst_klass = Class.new(self)
          inst_klass.define_method(:call, &proto)
          const_set(:"I_#{SecureRandom.hex(4)}", inst_klass)
          inst_klass.new
        end
      end

      # Predefined interface for Instrument before callback, do-no
      #
      # @param _session [Session] to use in callback
      #
      # @return [Nothing]
      #
      def before(_session); end

      # Predefined interface for Instrument after callback, do-no
      #
      # @param _session [Session] to use in callback
      #
      # @return [Nothing]
      #
      def after(_session); end

      # Predefined interface for Instrument finalization call, do-no
      #
      # @param _session [Session] to use in callback
      #
      # @return [Nothing]
      #
      def call(_session); end
    end
  end
end
