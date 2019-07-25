# frozen_string_literal: true

RSpec.describe BloodContracts::Instrumentation::Config do
  before do
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

  subject { described_class.new }

  describe "defaults on new instance" do
    let(:default_pool_size) { BCI::SessionFinalizer::DEFAULT_POOL_SIZE }

    it do
      expect(subject.instruments).to be_empty
      expect(subject.types).to be_empty
      expect(subject.finalizer_pool_size).to eq(default_pool_size)
      expect(subject.session_finalizer).to eq(:basic)
    end
  end

  describe "#instrument" do
    subject { BCI.configure { |config| config.send(:reset_types!) } }

    before do
      subject.types << Test::EmailType << Test::JsonType

      subject.instrument "Json", lambda { |session|
        puts "[SID:#{session.id}] #{session.result_type_name}"
      }
    end

    let(:instruments) { { /Json/i => [kind_of(BCI::Instrument)] } }
    let(:json_instruments) { [kind_of(BCI::Instrument)] }

    it do
      expect(subject.instruments).to match(instruments)
      expect(subject.types).to match_array([Test::EmailType, Test::JsonType])
      expect(Test::EmailType.instruments).to be_empty
      expect(Test::JsonType.instruments).to match_array(json_instruments)
    end
  end

  describe "#finalizer_pool_size=" do
    before do
      # Pool is only relevant for Fibers finalizer right now
      subject.session_finalizer = :fibers
      old_finalizer

      subject.finalizer_pool_size = new_pool_size
      new_finalizer
    end

    let(:old_finalizer) { BCI::SessionFinalizer.instance }
    let(:new_finalizer) { BCI::SessionFinalizer.instance }
    let(:new_pool_size) { 2 }

    it do
      expect(old_finalizer).not_to eq(new_finalizer)
      expect(new_finalizer.fibers.size).to eq(new_pool_size)
    end
  end

  describe "#session_finalizer=" do
    before do
      # Pool is only relevant for Fibers finalizer right now
      config = BCI::Config.new
      default_finalizer

      config.session_finalizer = :fibers
      fibers_finalizer

      config.session_finalizer = :threads
      threads_finalizer
    end

    let(:default_finalizer) { BCI::SessionFinalizer.instance }
    let(:fibers_finalizer)  { BCI::SessionFinalizer.instance }
    let(:threads_finalizer) { BCI::SessionFinalizer.instance }

    it do
      expect(default_finalizer).to eq(BCI::SessionFinalizer::Basic)
      expect(fibers_finalizer).to match(kind_of(BCI::SessionFinalizer::Fibers))
      expect(threads_finalizer).to eq(BCI::SessionFinalizer::Threads)
    end
  end
end
