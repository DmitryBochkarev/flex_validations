# frozen_string_literal: true

module FlexValidations
  # Call predicate on object
  #
  # @example
  #  odd = FlexValidations::Predicate.new(:odd?)
  #  odd.validate(1).success? #=> true
  #
  # @example Description
  #   > puts odd
  #   value.odd? should succeed
  #
  # @example Description of success result
  #   > puts odd.validate(1)
  #   1.odd? succeed
  #
  # @example Description of fail result
  #   > puts odd.validate(2)
  #   2.odd? failed
  #
  # @example Description when value doesn't respond to method
  #   > puts odd.validate("foo")
  #   "foo" of String isn't respond to method odd?
  class Predicate
    include Validation

    def initialize(method, *args)
      @method = method
      @args = args
    end

    # @param value [Object] Value to be validated
    #
    # @return [FlexValidations::Result]
    def validate(value)
      return not_respond(value) unless value.respond_to?(@method, false)

      ret = value.public_send(@method, *@args)

      return failed(value, ret) unless ret

      success(value, ret)
    end

    # @return [String]
    def to_s
      args = "(#{@args.map(&:inspect).join(', ')})" if @args.length > 0

      "value.#{@method}#{args} should succeed"
    end

    class SuccessMessage
      include ResultMessage

      def initialize(value, method, args, ret)
        @value = value
        @method = method
        @args = args
        @ret = ret
      end

      def to_s
        args = "(#{@args.map(&:inspect).join(', ')})" if @args.length > 0

        "#{@value.inspect}.#{@method}#{args} succeed"
      end
    end

    class NotRespondMessage
      include ResultMessage

      def initialize(value, method)
        @value = value
        @method = method
      end

      def to_s
        "#{@value.inspect} of #{@value.class} isn't respond to method #{@method}"
      end
    end

    class FailedMessage
      include ResultMessage

      def initialize(value, method, args)
        @value = value
        @method = method
        @args = args
      end

      def to_s
        args = "(#{@args.map(&:inspect).join(', ')})" if @args.length > 0

        "#{@value.inspect}.#{@method}#{args} failed"
      end
    end

    private

    def success(value, ret)
      msg = SuccessMessage.new(value, @method, @args, ret)

      Result::Success::Simple.new(self, msg, value, ret)
    end

    def not_respond(value)
      msg = NotRespondMessage.new(value, @method)

      Result::Fail::Simple.new(self, msg, value, false)
    end

    def failed(value, ret)
      msg = FailedMessage.new(value, @method, @args)

      Result::Fail::Simple.new(self, msg, value, ret)
    end
  end
end