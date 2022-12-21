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
    context "when the guess_feedback provided is not the right size" do
      let(:guess_feedback) { "NYG" }
      it "raises an error and does not call process_feedback" do
        expect(subject).not_to receive(:process_feedback)

        expect { subject.add_guess(guess:, guess_feedback:) }.to raise_error("Incomplete guess feedback")
      end
    end

    context "when the guess_feedback provided is the right size" do
      context "when the guess is the correct word" do
        let(:guess_feedback) { "GGGGG" }

        it "returns 'DONE' without calling any other methods" do
          expect(subject).not_to receive(:guess_contains_duplicated_letters?)
          expect(subject).not_to receive(:handle_multiple_letter_occurrences)
          expect(subject).not_to receive(:process_feedback)

          expect(subject.add_guess(guess:, guess_feedback:)).to eq("DONE")
        end
      end

      context "when the guess is not the correct word" do
        let(:guess_feedback) { "NNNYG" }
        context "when the guess does not contain any letter more than once" do
          it "does not call handle_multiple_letter_occurrences and calls process_feedback five times" do
            expect(subject).to receive(:guess_contains_duplicated_letters?).with(guess).and_return(false).once
            expect(subject).not_to receive(:handle_multiple_letter_occurrences)
            expect(subject).to receive(:process_feedback).exactly(5).times

            subject.add_guess(guess:, guess_feedback:)
          end
        end

        context "when the guess does contain a letter more than once" do
          let(:guess) { "SHEET" }

          it "calls handle_multiple_letter_occurrences and calls process_feedback five times" do
            expect(subject).to receive(:guess_contains_duplicated_letters?).with(guess).and_return(true).once
            expect(subject).to receive(:handle_multiple_letter_occurrences).with({ guess:, guess_feedback: }).once
            expect(subject).to receive(:process_feedback).exactly(5).times

            subject.add_guess(guess:, guess_feedback:)
          end
        end
      end
    end
  end

  describe "#handle_multiple_letter_occurrences" do
    let(:guess) { "SHEET" }

    context "when the letter(s) with multiple occurrences have the same feedback" do
      let(:guess_feedback) { "GNGGG" }

      it "does not set an occurrence limit" do
        expect(subject.instance_variable_get(:@known_letter_occurrences)).to eq({})

        subject.handle_multiple_letter_occurrences(guess:, guess_feedback:)

        expect(subject.instance_variable_get(:@known_letter_occurrences)).to eq({})
      end
    end

    context "when the letter(s) with multiple occurrences have differing feedback" do
      context "when all pieces of feedback indicate the letter is included ('Y' or 'G')" do
        let(:guess_feedback) { "GNYGN" }

        it "does not set an occurrence limit" do
          expect(subject.instance_variable_get(:@known_letter_occurrences)).to eq({})

          subject.handle_multiple_letter_occurrences(guess:, guess_feedback:)

          expect(subject.instance_variable_get(:@known_letter_occurrences)).to eq({})
        end
      end

      context "when pieces of feedback indicate the letter is included ('Y' or 'G') and not included ('N')" do
        let(:guess_feedback) { "GNGNN" }

        context "when the letter does not already have an occurrence limit set" do
          it "sets the occurrence limit for letters appearing more than once" do
            expect(subject.instance_variable_get(:@known_letter_occurrences)).to eq({})

            subject.handle_multiple_letter_occurrences(guess:, guess_feedback:)

            expect(subject.instance_variable_get(:@known_letter_occurrences)).to eq({ "E" => 1 })
          end
        end

        context "when the letter already has an occurrence limit set" do
          it "does not modify the occurrence limit recorded" do
            subject.instance_variable_set(:@known_letter_occurrences, { "E" => 1 })

            subject.handle_multiple_letter_occurrences(guess:, guess_feedback:)

            expect(subject.instance_variable_get(:@known_letter_occurrences)).to eq({ "E" => 1 })
          end
        end
      end
    end
  end

  describe "#process_feedback" do
    context "when the feedback is `G`" do
      let(:feedback) { "G" }

      it "calls add_to_correct_letters" do
        expect(subject).to receive(:add_to_correct_letters).with({ guess:, index: }).once
        expect(subject).not_to receive(:add_to_included_letters_wrong_spot)
        expect(subject).not_to receive(:add_to_not_included_letters)

        subject.process_feedback(guess:, feedback:, index:)
      end
    end

    context "when the feedback is `Y`" do
      let(:feedback) { "Y" }

      it "calls add_to_included_letters_wrong_spot" do
        expect(subject).not_to receive(:add_to_correct_letters)
        expect(subject).to receive(:add_to_included_letters_wrong_spot).with({ guess:, index: }).once
        expect(subject).not_to receive(:add_to_not_included_letters)

        subject.process_feedback(guess:, feedback:, index:)
      end
    end

    context "when the feedback is `N`" do
      let(:feedback) { "N" }

      it "calls add_to_not_included_letters" do
        expect(subject).not_to receive(:add_to_correct_letters)
        expect(subject).not_to receive(:add_to_included_letters_wrong_spot)
        expect(subject).to receive(:add_to_not_included_letters).with({ guess:, index: }).once

        subject.process_feedback(guess:, feedback:, index:)
      end
    end

    context "when the feedback is not 'N', 'Y', or 'G'" do
      let(:feedback) { "X" }

      it "raises an error" do
        expect(subject).not_to receive(:add_to_correct_letters)
        expect(subject).not_to receive(:add_to_included_letters_wrong_spot)
        expect(subject).not_to receive(:add_to_not_included_letters)

        expect { subject.process_feedback(guess:, feedback:, index:) }.to(
          raise_error("Invalid response. The only valid responses are 'N', 'Y', and 'G'.")
        )
      end
    end
  end

  describe "#add_to_correct_letters" do
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

  describe "#add_to_included_letters_wrong_spot" do
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

  describe "#add_to_not_included_letters" do
    context "when the letter is already in @not_included_letters" do
      it "does not add the letter again" do
        subject.instance_variable_set(:@not_included_letters, ["H"])

        subject.add_to_not_included_letters(guess:, index:)

        expect(subject.instance_variable_get(:@not_included_letters)).to eq(["H"])
      end
    end

    context "when the letter is not already in @not_included_letters" do
      context "when the letter is not in @known_letter_occurrences" do
        it "adds the letter to the instance variable" do
          expect(subject.instance_variable_get(:@known_letter_occurrences)).to eq({})
          expect(subject.instance_variable_get(:@not_included_letters)).to eq([])

          subject.add_to_not_included_letters(guess:, index:)

          expect(subject.instance_variable_get(:@not_included_letters)).to eq(["H"])
        end
      end
    end
  end
end
