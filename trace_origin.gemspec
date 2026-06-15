# frozen_string_literal: true

require_relative "lib/trace_origin/version"

Gem::Specification.new do |spec|
  spec.name = "trace_origin"
  spec.version = TraceOrigin::VERSION
  spec.authors = ["Giacomo Pozzobon"]
  spec.email = ["giacomo.pozzobon@zero.it"]

  spec.summary = "Capture the application path that created an ActiveRecord record."
  spec.description = "TraceOrigin helps debug where database records come from by storing a readable caller stack at creation time."
  spec.homepage = "https://github.com/zero/trace_origin"
  spec.license = "MIT"
  spec.required_ruby_version = "~> 3.0.5"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Compatibile con zero/spazio (Rails 7.0.6)
  spec.add_dependency "activerecord", ">= 6.1", "< 8.0"
  spec.add_dependency "activesupport", ">= 6.1", "< 8.0"

  spec.add_development_dependency "actionpack", "~> 7.0.6"
  spec.add_development_dependency "activejob", "~> 7.0.6"
  spec.add_development_dependency "railties", "~> 7.0.6"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "rspec-rails", "~> 6.0"
  spec.add_development_dependency "sqlite3", "~> 1.6"
end
