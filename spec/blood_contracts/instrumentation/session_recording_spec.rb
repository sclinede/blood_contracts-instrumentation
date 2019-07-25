# frozen_string_literal: true

RSpec.describe BloodContracts::Instrumentation::SessionRecording do
  before do
    BCI.reset_config!
    module Test
      class PhoneType < BC::Refined
        REGEX = /\A(\+7|8)(9|8)\d{9}\z/i
        def match
          context[:phone_input] = value.to_s
          return failure(:invalid_phone) if context[:phone_input] !~ REGEX
          context[:phone] = context[:phone_input]
          self
        end
      end

      class CustomInstrument
        def call(session)
          "[SID:#{session.id}] #{session.result_type_name}"
        end

        def before(session)
          session.extras[:started] = true
        end

        def after(session)
          session.extras[:finished] = true
        end
      end
    end

    BCI.configure { |cfg| cfg.instrument "Phone", custom_instrument }
  end

  let(:custom_instrument) { Test::CustomInstrument.new }

  it do
    expect(Test::PhoneType.instruments).to match_array([custom_instrument])
  end
end
