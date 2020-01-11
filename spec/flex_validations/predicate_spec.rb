RSpec.describe FlexValidations::Predicate do
  context 'when no arguments' do
    let(:validation) { described_class.new(:odd?) }

    describe '#to_s' do
      subject(:to_s) { validation.to_s }

      it { expect(to_s).to eq "value.odd? should succeed" }
    end

    describe '#validate' do
      subject(:validate) { validation.validate(value) }

      context 'when value does not respond to predicate' do
        let(:value) { 'foo' }

        it { expect(validate).to be_a FlexValidations::Result::Fail }

        describe '#success?' do
          subject(:success?) { validate.success? }

          it { expect(success?).to eq false }
        end

        describe '#fail?' do
          subject(:fail?) { validate.fail? }

          it { expect(fail?).to eq true }
        end

        describe '#message' do
          subject(:message) { validate.message }

          it { expect(message).to be_a FlexValidations::ResultMessage }

          describe '#to_s' do
            subject(:to_s) { message.to_s }

            it { expect(to_s).to eq "\"foo\" of String isn't respond to method odd?" }
          end
        end
      end

      context 'when predicate fails' do
        let(:value) { 2 }

        it { expect(validate).to be_a FlexValidations::Result::Fail }

        describe '#success?' do
          subject(:success?) { validate.success? }

          it { expect(success?).to eq false }
        end

        describe '#fail?' do
          subject(:fail?) { validate.fail? }

          it { expect(fail?).to eq true }
        end

        describe '#message' do
          subject(:message) { validate.message }

          it { expect(message).to be_a FlexValidations::ResultMessage }

          describe '#to_s' do
            subject(:to_s) { message.to_s }

            it { expect(to_s).to eq "2.odd? failed" }
          end
        end
      end

      context 'when predicate succeed' do
        let(:value) { 1 }

        it { expect(validate).to be_a FlexValidations::Result::Success }

        describe '#success?' do
          subject(:success?) { validate.success? }

          it { expect(success?).to eq true }
        end

        describe '#fail?' do
          subject(:fail?) { validate.fail? }

          it { expect(fail?).to eq false }
        end

        describe '#message' do
          subject(:message) { validate.message }

          it { expect(message).to be_a FlexValidations::ResultMessage }

          describe '#to_s' do
            subject(:to_s) { message.to_s }

            it { expect(to_s).to eq "1.odd? succeed" }
          end
        end
      end
    end
  end

  context 'when arguments passed' do
    let(:validation) { described_class.new(:start_with?, "Hello") }

    describe '#to_s' do
      subject(:to_s) { validation.to_s }

      it { expect(to_s).to eq "value.start_with?(\"Hello\") should succeed" }
    end

    describe '#validate' do
      subject(:validate) { validation.validate(value) }

      context 'when value does not respond to predicate' do
        let(:value) { 1 }

        it { expect(validate).to be_a FlexValidations::Result::Fail }

        describe '#success?' do
          subject(:success?) { validate.success? }

          it { expect(success?).to eq false }
        end

        describe '#fail?' do
          subject(:fail?) { validate.fail? }

          it { expect(fail?).to eq true }
        end

        describe '#message' do
          subject(:message) { validate.message }

          it { expect(message).to be_a FlexValidations::ResultMessage }

          describe '#to_s' do
            subject(:to_s) { message.to_s }

            it { expect(to_s).to eq "1 of Integer isn't respond to method start_with?" }
          end
        end
      end

      context 'when predicate fails' do
        let(:value) { 'foo' }

        it { expect(validate).to be_a FlexValidations::Result::Fail }

        describe '#success?' do
          subject(:success?) { validate.success? }

          it { expect(success?).to eq false }
        end

        describe '#fail?' do
          subject(:fail?) { validate.fail? }

          it { expect(fail?).to eq true }
        end

        describe '#message' do
          subject(:message) { validate.message }

          it { expect(message).to be_a FlexValidations::ResultMessage }

          describe '#to_s' do
            subject(:to_s) { message.to_s }

            it { expect(to_s).to eq "\"foo\".start_with?(\"Hello\") failed" }
          end
        end
      end

      context 'when predicate succeed' do
        let(:value) { "Hello, World!" }

        it { expect(validate).to be_a FlexValidations::Result::Success }

        describe '#success?' do
          subject(:success?) { validate.success? }

          it { expect(success?).to eq true }
        end

        describe '#fail?' do
          subject(:fail?) { validate.fail? }

          it { expect(fail?).to eq false }
        end

        describe '#message' do
          subject(:message) { validate.message }

          it { expect(message).to be_a FlexValidations::ResultMessage }

          describe '#to_s' do
            subject(:to_s) { message.to_s }

            it { expect(to_s).to eq "\"Hello, World!\".start_with?(\"Hello\") succeed" }
          end
        end
      end
    end
  end
end