# frozen_string_literal: true

require "flex_validations/version"

require "flex_validations/result"
require "flex_validations/result_message"
require "flex_validations/validation"

require "flex_validations/decorate"
require "flex_validations/predicate"
require "flex_validations/call"
require "flex_validations/all"
require "flex_validations/and"
require "flex_validations/or"
require "flex_validations/chain"

module FlexValidations
  # @api private
  class List
    def initialize(items)
      @items = items
    end

    def to_s
      listing = @items.map do |item|
        i = "- #{item}"

        if i.end_with?('.')
          i
        else
          "#{i};"
        end
      end.join("\n")

      if listing.end_with?('.')
        listing
      elsif listing.end_with?(';')
        "#{listing[0..-2]}."
      else
        "#{listing}."
      end
    end
  end

  # @api private
  class NumberedList
    def initialize(items)
      @items = items
    end

    def to_s
      listing = @items.map.with_index(1) do |item, n|
        i = "#{n}. #{item}"

        if i.end_with?('.')
          i
        else
          "#{i};"
        end
      end.join("\n")

      if listing.end_with?('.')
        listing
      elsif listing.end_with?(';')
        "#{listing[0..-2]}."
      else
        "#{listing}."
      end
    end
  end

  # @api private
  class IndentedString
    # @param original [#to_s]
    def initialize(original, level: 2, indentation: ' ')
      @original = original
      @level = level
      @indentation = indentation
    end

    def to_s
      @original.to_s.lines.map do |line|
        "#{@indentation * @level}#{line}"
      end.join('')
    end
  end
end
