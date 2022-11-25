require_relative "../../../lib/ordle_helper"

RSpec.describe OrdleHelper::WordFinder do
  let(:subject) { described_class.new }

  describe "#call" do
    it "returns true" do
      expect(subject.call).to be_truthy
    end
  end

  describe "#verify_guesses" do
    it "shows your guesses with the correct colors" do
      expect(subject.verify_guesses).to be_truthy
    end
  end

  describe "#potential_plural?" do
    it "returns true for a word ending in s" do
      expect(subject.potential_plural?("tacos")).to be_truthy
    end

    it "returns false for a word not ending in s" do
      expect(subject.potential_plural?("stack")).to be_falsey
    end
  end
end
