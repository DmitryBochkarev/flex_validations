# frozen_string_literal: true

module FlexValidations
  class Chain
    include Validation

    def initialize(*validations)
      @validations = validations
    end

    # @param value [Object] Value to be validated
    #
    # @return [FlexValidations::Result]
    def validate(value)
      successes = []
      v = value
      @validations.each do |validation|
        res = validation.validate(v)

        return failed(value, successes, res) if res.fail?

        successes.push(res)

        v = res.raw
      end

      SuccessResult.new(self, successes, value, successes.last.raw)
    end

    # @return [String]
    def to_s
      "chain of validations should succeed:\n#{IndentedString.new(NumberedList.new(@validations))}"
    end

    class SuccessResult
      include Result
      include Result::Success

      attr_reader :validation, :results, :value, :raw

      def initialize(validation, results, value, raw)
        @validation = validation
        @results = results
        @value = value
        @raw = raw
      end

      def message
        SuccessMessage.new(@results)
      end
    end

    class SuccessMessage
      include ResultMessage

      def initialize(results)
        @results = results
      end

      def to_s
        "chain of validation for #{@value.inspect} succeed:\n#{IndentedString.new(NumberedList.new(@results))}"
      end
    end

    class FailedMessage
      include ResultMessage

      def initialize(value, successes, res)
        @successes = successes
        @res = res
        @value = value
      end

      def to_s
        list = @successes + [@res]

        "chain of validation for #{@value.inspect} failed:\n#{IndentedString.new(NumberedList.new(list))}"
      end
    end

    private

    def failed(value, successes, res)
      Result::Fail::Simple.new(self, FailedMessage.new(value, successes, res), value, res.raw)
    end
  end
end