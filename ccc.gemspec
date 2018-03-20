# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ccc/version'

Gem::Specification.new do |spec|
  spec.name          = "ccc"
  spec.version       = Ccc::VERSION
  spec.authors       = ["hyounsub.shin"]
  spec.email         = ["begaborn@gmail.com"]

  spec.summary       = %q{Integration Crypto Currency Exchange.}
  spec.description   = %q{Integration Crypto Currency Exchange.}
  spec.homepage      = "https://github.com/begaborn."
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry-byebug"

  spec.add_runtime_dependency 'zaif', '0.0.2'
#  spec.add_runtime_dependency 'bitflyer', '0.1.2'
#  spec.add_runtime_dependency 'ruby_coincheck_client', '0.3.0'
  spec.add_runtime_dependency 'ruby_bitbankcc', '0.1.3'
  spec.add_runtime_dependency 'websocket-client-simple'
  spec.add_runtime_dependency 'activesupport'
  spec.add_runtime_dependency 'color_echo'
end
