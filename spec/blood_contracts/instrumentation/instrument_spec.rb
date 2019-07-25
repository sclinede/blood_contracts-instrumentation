# frozen_string_literal: true

RSpec.describe BloodContracts::Instrumentation::Instrument do
  before do
    module Test
      Instrument = BloodContracts::Instrumentation::Instrument.build(
        ->(session) { "[SID:#{session.id}] #{session.result_type_name}" },
        before: ->(session) { session.extras[:started] = true },
        after: ->(session) { session.extras[:finished] = true }
      )

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
  end

  let!(:session) { BloodContracts::Instrumentation::Session.new("SomeType") }

  describe ".build" do
    # FIXME: add case when after and before are not defined on custom instrument
    subject { BCI::Instrument.build(Test::CustomInstrument.new) }

    let(:message) do
      "[SID:#{session.id}] BloodContracts::Core::ContractFailure"
    end

    it do
      expect(subject).to match(kind_of(Test::CustomInstrument))

      session.start
      subject.before(session)
      expect(session.extras).to include(started: true)

      session.finish(BC::ContractFailure.new({ SomeType: :damn }))
      subject.after(session)

      expect(session.extras).to include(finished: true)

      expect(subject.call(session)).to eq(message)
    end
  end

  describe "#before" do
    before do
      session.start
      Test::Instrument.before(session)
    end

    it do
      expect(session.extras).to include(started: true)
      expect(session.extras).not_to include(finished: true)
    end
  end

  describe "#after" do
    before do
      session.start
      Test::Instrument.before(session)

      session.finish(BC::ContractFailure.new({ SomeType: :damn }))
      Test::Instrument.after(session)
    end

    it do
      expect(session.extras).to include(started: true)
      expect(session.extras).to include(finished: true)
    end
  end

  describe "#call" do
    before do
      session.start
      Test::Instrument.before(session)

      session.finish(BC::ContractFailure.new({ SomeType: :damn }))
      Test::Instrument.after(session)
    end

    subject { Test::Instrument.call(session) }

    let(:message) do
      "[SID:#{session.id}] BloodContracts::Core::ContractFailure"
    end

    it do
      is_expected.to eq(message)
      expect(session.extras).to include(started: true)
      expect(session.extras).to include(finished: true)
    end
  end
end
