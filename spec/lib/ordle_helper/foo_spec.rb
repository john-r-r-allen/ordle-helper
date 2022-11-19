require_relative "../../../lib/ordle_helper"

RSpec.describe OrdleHelper::Foo do
  let(:subject) { described_class.new }

  describe "#call" do
    it "returns true" do
      expect(subject.call).to be_truthy
    end
  end
end
