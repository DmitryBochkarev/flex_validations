RSpec.describe FlexValidations do
  it "has a version number" do
    expect(FlexValidations::VERSION).not_to be nil
  end

  example "case statement" do
    enum = lambda do |*values|
      FlexValidations::Or.new(
        *values.map { |v| FlexValidations::Predicate.new(:==, v) }
      )
    end

    expect(enum["foo", "bar"] === "bar").to eq true

    expect(enum["foo", "bar"] === "baz").to eq false
  end

  example "using as proc" do
    positive_integer = FlexValidations::And.new \
      FlexValidations::Predicate.new(:is_a?, Integer),
      FlexValidations::Predicate.new(:>, 0)

    expect([-2.5, -2, -1.5, -1, 0, 1, 1.5, 2, 2.5].select(&positive_integer)).to eq [1, 2]
  end

  example "array of hash maps" do
    string = FlexValidations::Predicate.new(:is_a?, String)
    hash = FlexValidations::Predicate.new(:is_a?, Hash)
    integer = FlexValidations::Predicate.new(:is_a?, Integer)
    positive = FlexValidations::Predicate.new(:positive?)
    positive_integer = FlexValidations::And.new(integer, positive)

    hash_of = lambda do |attrs|
      keys_validation =
        FlexValidations::Chain.new(
          FlexValidations::Call.new(:keys),
          FlexValidations::Decorate.new(Set), #=> Set.new(keys)
          FlexValidations::Predicate.new(:==, Set.new(attrs.keys))
        )

      validations =
        attrs.map do |key, validation|
          FlexValidations::Chain.new(FlexValidations::Call.new(:fetch, key), validation)
        end

      FlexValidations::And.new hash, keys_validation, *validations
    end

    array_of = lambda do |validation|
      FlexValidations::And.new(
        FlexValidations::Predicate.new(:is_a?, Array),
        FlexValidations::All.new(validation)
      )
    end

    maybe = lambda do |validation|
      FlexValidations::Or.new(
        FlexValidations::Predicate.new(:==, nil),
        validation
      )
    end

    enum = lambda do |*values|
      FlexValidations::Or.new(
        *values.map { |v| FlexValidations::Predicate.new(:==, v) }
      )
    end

    product = hash_of[
      "id" => positive_integer,
      "title" => string,
      "subtitle" => maybe[string],
      "tags" => array_of[string],
      "category" => enum["closes", "jewelry"]
    ]

    products = array_of[product]

    expect(products.to_s).to eq <<~TEXT.rstrip
      all validations should succeed:
        - value.is_a?(Array) should succeed;
        - all elements should pass following validation:
          all validations should succeed:
            - value.is_a?(Hash) should succeed;
            - chain of validations should succeed:
              1. value.keys should not raise error;
              2. decorate value with Set;
              3. value.==(#<Set: {"id", "title", "subtitle", "tags", "category"}>) should succeed.
            - chain of validations should succeed:
              1. value.fetch("id") should not raise error;
              2. all validations should succeed:
                - value.is_a?(Integer) should succeed;
                - value.positive? should succeed.
            - chain of validations should succeed:
              1. value.fetch("title") should not raise error;
              2. value.is_a?(String) should succeed.
            - chain of validations should succeed:
              1. value.fetch("subtitle") should not raise error;
              2. any of validation should succeed:
                - value.==(nil) should succeed;
                - value.is_a?(String) should succeed.
            - chain of validations should succeed:
              1. value.fetch("tags") should not raise error;
              2. all validations should succeed:
                - value.is_a?(Array) should succeed;
                - all elements should pass following validation:
                  value.is_a?(String) should succeed.
            - chain of validations should succeed:
              1. value.fetch("category") should not raise error;
              2. any of validation should succeed:
                - value.==("closes") should succeed;
                - value.==("jewelry") should succeed.
    TEXT

    data = [
      {
        "id" => 1,
        "title" => "book",
        "subtitle" => nil,
        "tags" => ["nonfiction"],
        "category" => "closes"
      },
      {
        "id" => 2,
        "title" => "another book",
        "tags" => ["fiction"],
        "subtitle" => "not a favorite one",
        "category" => "jewelry"
      }
    ]

    expect(products.validate(data).message.to_s).to eq <<~TEXT.rstrip
      all validations succeed:
        - [{"id"=>1, "title"=>"book", "subtitle"=>nil, "tags"=>["nonfiction"], "category"=>"closes"}, {"id"=>2, "title"=>"another book", "tags"=>["fiction"], "subtitle"=>"not a favorite one", "category"=>"jewelry"}].is_a?(Array) succeed;
        - all elements passed following validation:
          all validations should succeed:
            - value.is_a?(Hash) should succeed;
            - chain of validations should succeed:
              1. value.keys should not raise error;
              2. decorate value with Set;
              3. value.==(#<Set: {"id", "title", "subtitle", "tags", "category"}>) should succeed.
            - chain of validations should succeed:
              1. value.fetch("id") should not raise error;
              2. all validations should succeed:
                - value.is_a?(Integer) should succeed;
                - value.positive? should succeed.
            - chain of validations should succeed:
              1. value.fetch("title") should not raise error;
              2. value.is_a?(String) should succeed.
            - chain of validations should succeed:
              1. value.fetch("subtitle") should not raise error;
              2. any of validation should succeed:
                - value.==(nil) should succeed;
                - value.is_a?(String) should succeed.
            - chain of validations should succeed:
              1. value.fetch("tags") should not raise error;
              2. all validations should succeed:
                - value.is_a?(Array) should succeed;
                - all elements should pass following validation:
                  value.is_a?(String) should succeed.
            - chain of validations should succeed:
              1. value.fetch("category") should not raise error;
              2. any of validation should succeed:
                - value.==("closes") should succeed;
                - value.==("jewelry") should succeed.
    TEXT
    expect(products.validate(data)).to be_success

    data = [
      {
        "id" => 2,
        "title" => "another book",
        "tags" => ["fiction"],
        "subtitle" => 1,
        "category" => "jewelry"
      }
    ]

    expect(products.validate(data).message.to_s).to eq <<~TEXT.rstrip
      validation for {"id"=>2, "title"=>"another book", "tags"=>["fiction"], "subtitle"=>1, "category"=>"jewelry"} at index 0 failed:
        chain of validation for {"id"=>2, "title"=>"another book", "tags"=>["fiction"], "subtitle"=>1, "category"=>"jewelry"} failed:
          1. {"id"=>2, "title"=>"another book", "tags"=>["fiction"], "subtitle"=>1, "category"=>"jewelry"}.fetch("subtitle") returned 1;
          2. all validations failed:
            - 1.==(nil) failed;
            - 1.is_a?(String) failed.
    TEXT
    expect(products.validate(data)).to be_fail

    data = [
      {
        "id" => 2,
        "title" => "another book",
        "tags" => ["fiction"],
        "subtitle" => "subtitle",
        "category" => "foo"
      }
    ]

    expect(products.validate(data).message.to_s).to eq <<~TEXT.rstrip
      validation for {"id"=>2, "title"=>"another book", "tags"=>["fiction"], "subtitle"=>"subtitle", "category"=>"foo"} at index 0 failed:
        chain of validation for {"id"=>2, "title"=>"another book", "tags"=>["fiction"], "subtitle"=>"subtitle", "category"=>"foo"} failed:
          1. {"id"=>2, "title"=>"another book", "tags"=>["fiction"], "subtitle"=>"subtitle", "category"=>"foo"}.fetch("category") returned "foo";
          2. all validations failed:
            - "foo".==("closes") failed;
            - "foo".==("jewelry") failed.
    TEXT
    expect(products.validate(data)).to be_fail
  end
end
