# frozen_string_literal: true

RSpec.describe BloodContracts::Instrumentation::FailedMatch do
  subject do
    begin
      1 / 0
    rescue StandardError => ex
      described_class.new(ex, context: validation_context)
    end
  end

  let(:validation_context) do
    { some: "data", exception: kind_of(ZeroDivisionError) }
  end

  it do
    is_expected.to be_invalid
    expect(subject.match).to eq(subject)
    expect(subject.exception).to match(kind_of(ZeroDivisionError))
    expect(subject.context).to match(validation_context)
  end
end
