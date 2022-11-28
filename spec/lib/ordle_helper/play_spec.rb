require_relative "../../../lib/ordle_helper"

RSpec.describe OrdleHelper::Play do
  let(:subject) { described_class.new(input: input, output: output) }
  let(:output) { StringIO.new }

  describe "#determine_and_initiate_game" do
    describe "when wordle is selected (option W)" do
      let(:input) { StringIO.new("W\n") }

      it "calls the call method with no parameters" do
        expect(subject).to receive(:call).with(no_args).once

        subject.determine_and_initiate_game

        expect(output.string).to(
          eq(
            "Which ordle game are you playing? ".light_blue +
              "Please enter one of the following letters:".light_blue +
              "\n\t(W)ordle\n\t(Q)uordle\n\t(O)ctordle\n"
          )
        )
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
