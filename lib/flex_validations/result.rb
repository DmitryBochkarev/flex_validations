# frozen_string_literal: true

module FlexValidations
  # @abstract
  module Result
    # @abstract
    #
    # @return [Boolean]
    def success?
      raise 'not implemented'
    end

    # @abstract
    #
    # @return [Boolean]
    def fail?
      raise 'not implemented'
    end

    alias failure? fail?

    # @abstract
    #
    # @return [FlexValidations::ResultMessage]
    def message
      raise 'not implemented'
    end

    # @abstract Original validation of result
    #
    # @return [FlexValidations::Validation]
    def validation
      raise 'not implemented'
    end

    # @abstract Original object on which {#validation} was performed
    #
    # @return [Object]
    def value
      raise 'not implemented'
    end

    # @abstract
    #
    # @return [Object]
    def raw
      raise 'not implemented'
    end

    def to_s
      message.to_s
    end

    module Success
      def success?
        true
      end

      def fail?
        false
      end

      class Simple
        include Result
        include Success

        attr_reader :validation, :message, :value, :raw

        def initialize(validation, message, value, raw)
          @validation = validation
          @message = message
          @value = value
          @raw = raw
        end
      end

      class Composite
        include Result
        include Success

        attr_reader :validation, :original, :value, :raw

        def initialize(validation, original, message, value, raw)
          @validation = validation
          @original = original
          @message = message
          @value = value
          @raw = raw
        end

        def message
          @message || @original.message
        end
      end
    end

    module Fail
      def success?
        false
      end

      def fail?
        true
      end

      class Simple
        include Result
        include Fail

        attr_reader :validation, :message, :value, :raw

        def initialize(validation, message, value, raw)
          @validation = validation
          @message = message
          @value = value
          @raw = raw
        end
      end

      class Composite
        include Result
        include Fail

        attr_reader :validation, :original, :value, :raw

        def initialize(validation, original, message, value, raw)
          @validation = validation
          @original = original
          @message = message
          @value = value
        end

        def message
          @message || @original.message
        end
      end
    end
  end
end