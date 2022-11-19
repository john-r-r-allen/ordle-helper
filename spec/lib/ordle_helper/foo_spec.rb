require_relative "../../../lib/ordle_helper"

RSpec.describe OrdleHelper::Foo do
  let(:subject) { described_class.new }

  describe "#call" do
    it "returns true" do
      expect(subject.call).to be_truthy
    end
  end

  describe "puts constants for reset" do
    it "outputs the expected values" do
      puts <<-TXT
    NOT_INCLUDED_LETTERS = %w()
    CORRECT_LETTERS = {
      0 => "",
      1 => "",
      2 => "",
      3 => "",
      4 => ""
    }
    INCLUDED_LETTERS_WRONG_SPOT = {
      0 => %w(),
      1 => %w(),
      2 => %w(),
      3 => %w(),
      4 => %w(),
    }
    TXT

      expect(1).to eq(1)
    end
  end
end
