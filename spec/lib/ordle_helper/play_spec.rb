require_relative "../../../lib/ordle_helper"

PUTS_ENDING = "\n"

RSpec.describe OrdleHelper::Play do
  let(:subject) { described_class.new(input: input, output: output) }
  let(:output) { StringIO.new }

  describe "constant values" do
    it "MAX_NUMBER_OF_TURNS has not changed" do
      expect(described_class::MAX_NUMBER_OF_TURNS).to eq(13)
    end

    it "EXIT_WORDS has not changed" do
      expect(described_class::EXIT_WORDS).to eq(%w(DONE QUIT EXIT STOP))
    end

    context "MESSAGES" do
      it "is a hash" do
        expect(described_class::MESSAGES.is_a?(Hash)).to be true
      end

      it "has keys of GAME_SELECTION, GAME_START, and GUESS_PROMPT" do
        expect(described_class::MESSAGES.key?(:GAME_SELECTION)).to be true
        expect(described_class::MESSAGES.key?(:GAME_START)).to be true
        expect(described_class::MESSAGES.key?(:GUESS_PROMPT)).to be true
      end

      it "MESSAGES[:GAME_SELECTION] has not changed" do
        expect(described_class::MESSAGES[:GAME_SELECTION]).to(
          eq(
            "Which ordle game are you playing? Please enter one of the following letters:".light_blue +
              "\n\t(W)ordle" +
              "\n\t(Q)uordle" +
              "\n\t(O)ctordle"
          )
        )
      end

      it "MESSAGES[:GAME_START] has not changed" do
        expect(described_class::MESSAGES[:GAME_START]).to eq("Initiating word finder.".light_blue)
      end

      it "MESSAGES[:GUESS_PROMPT] has not changed" do
        expect(described_class::MESSAGES[:GUESS_PROMPT]).to(
          eq("Enter your guess. If you would like to exit, type 'done' and press Enter/Return.".light_blue)
        )
      end
    end
  end

  describe "#determine_and_initiate_game" do
    describe "when wordle is selected (option W)" do
      let(:input) { StringIO.new("W\n") }

      it "calls the call method with no parameters" do
        expect(subject).to receive(:call).with(no_args).once

        subject.determine_and_initiate_game

        expect(output.string).to eq(described_class::MESSAGES[:GAME_SELECTION] + PUTS_ENDING)
      end

      describe "when the option is passed lowercase" do
        let(:input) { StringIO.new("w\n") }

        it "calls the call method with no parameters" do
          expect(subject).to receive(:call).with(no_args).once

          subject.determine_and_initiate_game
        end
      end
    end

    describe "when quordle is selected (option Q)" do
      let(:input) { StringIO.new("Q\n") }

      it "calls the call method with no parameters" do
        expect(subject).to receive(:call).with(4).once

        subject.determine_and_initiate_game
      end

      describe "when the option is passed lowercase" do
        let(:input) { StringIO.new("q\n") }

        it "calls the call method with no parameters" do
          expect(subject).to receive(:call).with(4).once

          subject.determine_and_initiate_game
        end
      end
    end

    describe "when octordle is selected (option O)" do
      let(:input) { StringIO.new("O\n") }

      it "calls the call method with no parameters" do
        expect(subject).to receive(:call).with(8).once

        subject.determine_and_initiate_game
      end

      describe "when the option is passed lowercase" do
        let(:input) { StringIO.new("o\n") }

        it "calls the call method with no parameters" do
          expect(subject).to receive(:call).with(8).once

          subject.determine_and_initiate_game
        end
      end
    end

    describe "when given an invalid option" do
      let(:input) { StringIO.new("what the heck am I doing?!?!?\n") }

      it "raises an error" do
        expect(subject).not_to receive(:call)

        expect { subject.determine_and_initiate_game }.to(
          raise_error(StandardError, "#{input.string.chomp.upcase} is not a valid response.")
        )
      end
    end
  end
end
