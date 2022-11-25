require_relative "../../../lib/ordle_helper"

RSpec.describe OrdleHelper::WordFinder do
  let(:subject) { described_class.new }

  describe "#potential_plural?" do
    it "returns true for a word ending in s" do
      expect(subject.potential_plural?("tacos")).to be_truthy
    end

    it "returns false for a word not ending in s" do
      expect(subject.potential_plural?("stack")).to be_falsey
    end
  end
end
