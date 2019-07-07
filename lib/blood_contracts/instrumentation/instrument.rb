module BloodContracts
  module Instrumentation
    class Instrument
      class << self
        def build(proto, before: nil, after: nil)
          raise ArgumentError unless proto.respond_to?(:call)
          call = proto.method(:call) unless proto.is_a?(Proc)
          call ||= proto

          before ||= proto.method(:before) if proto.respond_to?(:before)
          after  ||= proto.method(:after) if proto.respond_to?(:after)

          inst = Class.new(self)
          inst.define_method(:call, &call)
          inst.define_method(:before, &before) if before.respond_to?(:call)
          inst.define_method(:after, &after) if after.respond_to?(:call)
          const_set(:"I_#{SecureRandom.hex(4)}", inst)
          inst
        end
      end

      def before(_session); end
      def after(_session); end
      def call(_session); end

      def notify!(session)
        Instrumentation.notify!(self, session)
      end
    end
  end
end
