# frozen_string_literal: true

RSpec.describe BloodContracts::Instrumentation do
  before do
    BCI.configure { |config| config.send(:reset_types!) }

    module Test
      require "json"

      class EmailType < BC::Refined
        REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
        def match
          context[:email_input] = value.to_s
          return failure(:invalid_email) if context[:email_input] !~ REGEX
          context[:email] = context[:email_input]
          self
        end
      end

      class JsonType < BC::Refined
        def match
          context[:parsed] = JSON.parse(value.to_s)
          self
        end
      end
    end
  end

  describe ".configure" do
    subject do
      described_class.configure { |cfg| cfg.finalizer_pool_size = 5 }
    end

    it do
      is_expected.to eq(described_class.config)
      expect(subject.finalizer_pool_size).to eq(5)
    end
  end

  describe ".register_type" do
    before { described_class.register_type(Test::JsonType) }

    subject { described_class.config }

    it { expect(subject.types).to include(Test::JsonType) }
  end

  describe ".select_instruments" do
    before do
      described_class.configure do |cfg|
        cfg.instrument "Json", lambda { |session|
          puts "[SID:#{session.id}] #{session.result_type_name}"
        }
      end
    end

    subject { described_class.select_instruments(type) }

    context "when type matches instruments condition" do
      let(:type) { Test::JsonType.name }

      it do
        is_expected.to match_array([kind_of(BCI::Instrument)])
      end
    end

    context "when type doesn't match instruments condition" do
      let(:type) { Test::EmailType.name }

      it { is_expected.to be_empty }
    end
  end

  describe ".reset_session_finalizer!" do
    before do
      described_class.configure { |cfg| cfg.session_finalizer = :fibers }
      old_finalizer
    end

    let(:old_finalizer) { described_class::SessionFinalizer.instance }

    subject { described_class.reset_session_finalizer! }

    it { is_expected.not_to eq(old_finalizer) }
  end
end
