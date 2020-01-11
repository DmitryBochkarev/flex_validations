# frozen_string_literal: true

module FlexValidations
  # Not a really validation but handy class for complex validations
  #
  # @example
  #   hash = FlexValidations::Chain.new(
  #     FlexValidations::Call.new(:keys),
  #     FlexValidations::Decorate.new(Set),
  #     FlexValidations::Predicate.new(:==, Set.new(["id", "title"]))
  #   )
  class Decorate
    include Validation

    def initialize(decorator_class, *decorator_args)
      @decorator_class = decorator_class
      @decorator_args = decorator_args
    end

    # @param value [Object] Value to be validated
    #
    # @return [FlexValidations::Result]
    def validate(value)
      new_val = @decorator_class.new value, *@decorator_args

      Result::Success::Simple.new(self, SuccessMessage.new(value, new_val), value, new_val)
    end

    # @return [String]
    def to_s
      "decorate value with #{@decorator_class}"
    end

    class SuccessMessage
      def initialize(value, ret)
        @value = value
        @ret = ret
      end

      def to_s
        "decorated #{@value.inspect} now #{@ret.inspect}"
      end
    end
  end
end