# frozen_string_literal: true

module FlexValidations
  # @abstract
  module ResultMessage
    # @abstract
    #
    # @return [String]
    def to_s
      raise 'not implemented'
    end
  end
end