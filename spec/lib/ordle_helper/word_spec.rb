RSpec.describe OrdleHelper::Word do
  let(:subject) { described_class.new }
  let(:guess) { "SHARE" }
  let(:index) { 1 }
  let(:empty_correct_letters) do
    {
      0 => "",
      1 => "",
      2 => "",
      3 => "",
      4 => ""
    }
  end
  let(:empty_included_letters_wrong_spot_hash) do
    {
      0 => %w(),
      1 => %w(),
      2 => %w(),
      3 => %w(),
      4 => %w()
    }
  end

  describe "#add_guess" do

  end

  fdescribe "#add_to_correct_letters" do
    context "when the correct letter is already set at that position" do
      context "when the set value matches the value attempting to be set" do
        it "it returns successfully" do
          subject.instance_variable_set(:@correct_letters, empty_correct_letters.merge({ index => "H" }))

          subject.add_to_correct_letters(guess:, index:)

          expect(subject.instance_variable_get(:@correct_letters)).to eq(empty_correct_letters.merge({ index => "H" }))
        end
      end

      context "when the set value does not match the value attempting to be set" do
        it "raises an error" do
          subject.instance_variable_set(:@correct_letters, empty_correct_letters.merge({ index => "T" }))

          expect { subject.add_to_correct_letters(guess:, index:) }.to(
            raise_error(described_class::RESET_CORRECT_LETTER_ERROR)
          )
        end
      end
    end

    context "when the correct letter is not yet set" do
      it "sets the provided letter at the provided index" do
        expect(subject.instance_variable_get(:@correct_letters)).to eq(empty_correct_letters)

        subject.add_to_correct_letters(guess:, index:)

        expect(subject.instance_variable_get(:@correct_letters)).to eq(empty_correct_letters.merge({ index => "H" }))
      end
    end
  end

  fdescribe "#add_to_included_letters_wrong_spot" do
    context "when the letter is already in the included_letters_wrong_spot instance variable hash at that index" do
      it "does not add the letter" do
        subject.instance_variable_set(
          :@included_letters_wrong_spot,
          empty_included_letters_wrong_spot_hash.merge({ index => ["H"] })
        )

        subject.add_to_included_letters_wrong_spot(guess:, index:)

        expect(subject.instance_variable_get(:@included_letters_wrong_spot)).to(
          eq(empty_included_letters_wrong_spot_hash.merge({ index => ["H"] }))
        )
      end
    end

    context "when the letter is not already in the included_letters_wrong_spot instance variable hash at that index" do
      it "it adds the letter at the given index" do
        expect(subject.instance_variable_get(:@included_letters_wrong_spot)).to(
          eq(empty_included_letters_wrong_spot_hash)
        )

        subject.add_to_included_letters_wrong_spot(guess:, index:)

        expect(subject.instance_variable_get(:@included_letters_wrong_spot)).to(
          eq(empty_included_letters_wrong_spot_hash.merge({ index => ["H"] }))
        )
      end
    end
  end

  fdescribe "#add_to_not_included_letters" do
    context "when the letter is already in the not_included_letters instance variable" do
      it "does not add the letter again" do
        subject.instance_variable_set(:@not_included_letters, ["H"])

        subject.add_to_not_included_letters(guess:, index:)

        expect(subject.instance_variable_get(:@not_included_letters)).to eq(["H"])
      end
    end

    context "when the letter is not already in the not_included_letters instance variable" do
      it "adds the letter to the instance variable" do
        expect(subject.instance_variable_get(:@not_included_letters)).to eq([])

        subject.add_to_not_included_letters(guess:, index:)

        expect(subject.instance_variable_get(:@not_included_letters)).to eq(["H"])
      end
    end
  end
end
