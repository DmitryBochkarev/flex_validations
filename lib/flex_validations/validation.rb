# frozen_string_literal: true

module FlexValidations
  # @abstract Validation should define {#validate} and {#to_s} methods
  module Validation
    # @abstract Do validation of value
    #
    # @param value [Object] Value to be validated
    #
    # @return [FlexValidations::Result]
    #
    # @example
    #   odd.validate(1).success? #=> true
    #
    # @example
    #   odd.validate(2).fail? #=> true
    def validate(value)
      raise 'not implemented'
    end

    # @abstract Returns description of validation
    #
    # @return [String]
    def to_s
      raise 'not implemented'
    end

    # @param [Object] Value to match
    #
    # @return [Boolean]
    #
    # @example
    #   case 1
    #   when odd
    #     puts "its odd number"
    #   end
    def ===(value)
      validate(value).success? || super
    end

    # @return [Proc]
    #
    # @example
    #   [1, 2, 3].select(&odd) #=> [1, 3]
    def to_proc
      proc { |value| validate(value).success? }
    end
  end
end