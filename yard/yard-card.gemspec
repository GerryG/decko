# -*- encoding : utf-8 -*-

yard_card_version = "0.0.1"

Gem::Specification.new do |s|
  s.name = "yard-card"
  s.version = yard_card_version

  s.authors =
    [ "Gerry Gleason" ]
  s.email = ["info@decko.org"]

  s.summary       = "yard plugin"
  s.description   =
    "Attempted plugin for yard to help or docs"
  s.homepage      = "http://decko.org"
  s.licenses      = ["GPL-2.0", "GPL-3.0"]

  s.files         = Dir["LICENSE", "GPL", "{lib}/**/*"]

  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 2.3"

  s.add_runtime_dependency 'yard', '~> 0.7'
end
