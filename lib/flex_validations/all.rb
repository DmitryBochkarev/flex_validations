# frozen_string_literal: true

module FlexValidations
  # Check if all elements in enumerable are valid
  #
  # @example
  #  all_odd = FlexValidations::All.new(odd)
  #  all_odd.validate([1, 2, 3]).success? # => false
  class All
    # @param validation [FlexValidations::Validation] validation which performed on each element
    def initialize(validation)
      @validation = validation
    end

    # @param value [#each] Value to be validated
    #
    # @return [FlexValidations::Result]
    def validate(value)
      return not_enumerable(value) unless value.respond_to?(:each, false)

      value.each.with_index do |element, index|
        res = @validation.validate(element)

        return failed(value, res, element, index) if res.fail?
      end

      success(value)
    end

    # @return [String]
    def to_s
      "all elements should pass following validation:\n" \
        "#{IndentedString.new(@validation)}"
    end

    class SuccessMessage
      include ResultMessage

      def initialize(validation)
        @validation = validation
      end

      def to_s
        "all elements passed following validation:\n" \
          "#{IndentedString.new(@validation)}"
      end
    end

    class NotEnumerableMessage
      include ResultMessage

      def initialize(value)
        @value = value
      end

      def to_s
        "#{@value.inspect} of #{@value.class} isn't respond to method \"each\""
      end
    end

    class FailedMessage
      include ResultMessage

      def initialize(res, element, index)
        @res = res
        @element = element
        @index = index
      end

      def to_s
        "validation for #{@element.inspect} at index #{@index} failed:\n" \
          "#{IndentedString.new(@res.message)}"
      end
    end

    private

    def success(value)
      Result::Success::Simple.new \
        self,
        SuccessMessage.new(@validation),
        value,
        value
    end

    def not_enumerable(value)
      Result::Fail::Simple.new \
        self,
        NotEnumerableMessage.new(value),
        value,
        false
    end

    def failed(value, res, element, index)
      Result::Fail::Composite.new \
        self,
        res,
        FailedMessage.new(res, element, index),
        value,
        res.raw
    end
  end
end