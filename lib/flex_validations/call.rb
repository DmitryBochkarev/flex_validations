# frozen_string_literal: true

module FlexValidations
  class Call
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

      begin
        ret = value.public_send(@method, *@args)
        success(value, ret)
      rescue => e
        failed(value, e)
      end
    end

    # @return [String]
    def to_s
      args = "(#{@args.map(&:inspect).join(', ')})" if @args.length > 0

      "value.#{@method}#{args} should not raise error"
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

        "#{@value.inspect}.#{@method}#{args} returned #{@ret.inspect}"
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

      def initialize(value, method, args, error)
        @value = value
        @method = method
        @args = args
        @error = error
      end

      def to_s
        args = "(#{@args.map(&:inspect).join(', ')})" if @args.length > 0

        "#{@value.inspect}.#{@method}#{args} raised error #{@error.class}: #{@error}"
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

    def failed(value, error)
      msg = FailedMessage.new(value, @method, @args, error)

      Result::Fail::Simple.new(self, msg, value, error)
    end
  end
end