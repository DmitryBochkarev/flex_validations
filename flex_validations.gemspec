require_relative 'lib/flex_validations/version'

Gem::Specification.new do |spec|
  spec.name          = "flex_validations"
  spec.version       = FlexValidations::VERSION
  spec.authors       = ["Dmitry Bochkarev"]
  spec.email         = ["dimabochkarev@gmail.com"]

  spec.summary       = %q{Object Oriented Validation Library}
  spec.description   = %q{Object Oriented Validation Library}
  spec.homepage      = "https://github.com/DmitryBochkarev/flex_validations"
  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/DmitryBochkarev/flex_validations"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
