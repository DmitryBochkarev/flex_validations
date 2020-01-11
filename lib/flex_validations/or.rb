# frozen_string_literal: true

module FlexValidations
  class Or
    include Validation

    def initialize(*validations)
      @validations = validations
    end

    # @param value [Object] Value to be validated
    #
    # @return [FlexValidations::Result]
    def validate(value)
      fails = []

      @validations.each do |validation|
        res = validation.validate(value)

        return Result::Success::Composite.new(self, validation, res.message, value, res.raw) if res.success?

        fails.push(res)
      end

      Result::Fail::Simple.new(self, FailedMessage.new(fails), value, value)
    end

    # @return [String]
    def to_s
      "any of validation should succeed:\n#{IndentedString.new(List.new(@validations))}"
    end

    class FailedMessage
      include ResultMessage

      def initialize(fails)
        @fails = fails
      end

      def to_s
        "all validations failed:\n#{IndentedString.new(List.new(@fails))}"
      end
    end
  end
end