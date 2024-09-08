require_relative "lib/spond/version"

Gem::Specification.new do |spec|
  spec.name = "spond"
  spec.version = Spond::VERSION
  spec.authors = ["Graeme Porteous"]
  spec.email = ["graeme@rgbp.co.uk"]

  spec.summary = "Unofficial Ruby client library for the Spond API."
  spec.description = spec.summary
  spec.homepage = "https://github.com/gbp/spond-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.4.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
