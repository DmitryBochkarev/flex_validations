# frozen_string_literal: true

module FlexValidations
  # Perform all validations on value to succeed
  #
  # @example
  #  positive_integer = FlexValidations::And.new \
  #    FlexValidations::Predicate.new(:is_a?, Integer),
  #    FlexValidations::Predicate.new(:positive?)
  #  [-2, -1.5, -1, 0, 1, 1.5, 2].select(&positive_integer) #=> [1, 2]
  #
  # @example Description
  #   > puts positive_integer
  #   all validations should succeed:
  #     - value.is_a?(Integer) should succeed;
  #     - value.positive? should succeed.
  #
  # @example Success result description
  #   > puts positive_integer.validate(1)
  #   all validations succeed:
  #     - 1.is_a?(Integer) succeed;
  #     - 1.positive? succeed.
  #
  # @example Fail description
  #   > puts positive_integer.validate(-2)
  #   -2.positive? failed
  class And
    include Validation

    # @param validations [Array<FlexValidations::Validation>] all validations that
    #   value should satisfy
    #
    # @return [FlexValidations::Validation]
    def initialize(*validations)
      @validations = validations
    end

    # @param value [Object] Value to be validated
    #
    # @return [FlexValidations::Result]
    def validate(value)
      successes = []

      @validations.each do |validation|
        res = validation.validate(value)

        return failed(res, value) if res.fail?

        successes.push(res)
      end

      success(successes, value)
    end

    # @return [String]
    def to_s
      "all validations should succeed:\n" \
        "#{IndentedString.new(List.new(@validations))}"
    end

    class SuccessMessage
      include ResultMessage

      def initialize(successes)
        @successes = successes
      end

      def to_s
        "all validations succeed:\n#{IndentedString.new(List.new(@successes))}"
      end
    end

    private

    def success(successes, value)
      Result::Success::Simple.new \
        self,
        SuccessMessage.new(successes),
        value,
        value
    end

    def failed(res, value)
      Result::Fail::Composite.new(self, res, nil, value, res.raw)
    end
  end
end