# frozen_string_literal: true

RSpec.describe BloodContracts::Instrumentation::Session do
  before do
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
    end
  end

  subject { described_class.new(Test::PhoneType.name) }

  describe "defaults on new instance" do
    it do
      expect(subject.extras).to be_empty

      expect(subject.context).to be_empty
      expect(subject.matcher_type_name).to eq(Test::PhoneType.name)

      expect(subject.result_type_name).to be_nil
      expect(subject.id.size).to eq(20)

      expect(subject.started_at).to be_nil
      expect(subject.finished_at).to be_nil

      expect(subject.scope).to be_nil
      expect(subject.path).to be_nil
    end
  end

  describe "#start" do
    before { subject.start }

    it do
      expect(subject.extras).to be_empty
      expect(subject.context).to be_empty

      expect(subject.matcher_type_name).to eq(Test::PhoneType.name)
      expect(subject.result_type_name).to be_nil

      expect(subject.id.size).to eq(20)

      expect(subject.started_at).to match(kind_of(Time))
      expect(subject.finished_at).to be_nil

      expect(subject.scope).to be_nil
      expect(subject.path).to be_nil
    end
  end

  describe "#finish" do
    before do
      subject.start
      subject.finish(invalid_match)
    end

    let(:invalid_match) { Test::PhoneType.match("asdasdsdas") }

    it do
      expect(subject.extras).to be_empty
      expect(subject.context).to match(invalid_match.context)

      expect(subject.matcher_type_name).to eq(Test::PhoneType.name)
      expect(subject.result_type_name).to eq(BC::ContractFailure.name)

      expect(subject.id.size).to eq(20)

      expect(subject.started_at).to match(kind_of(Time))
      expect(subject.finished_at).to match(kind_of(Time))

      expect(subject.scope).to eq(described_class::NO_SCOPE)
      expect(subject.path).to eq(described_class::NO_VALIDATION_PATH)
    end
  end
end
