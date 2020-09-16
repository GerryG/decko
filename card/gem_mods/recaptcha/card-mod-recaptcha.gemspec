# -*- encoding : utf-8 -*-

Gem::Specification.new do |s|
  s.name = "card-mod-recaptcha"
  s.version = "0.5"

  s.authors = ["Ethan McCutchen", "Philipp Kühl", "Gerry Gleason"]
  s.email = ["info@decko.org"]

  s.summary       = "recaptcha support for decko"
  s.description   = ""
  s.homepage      = "http://decko.org"
  s.licenses      = ["GPL-2.0", "GPL-3.0"]

  s.files         = Dir["VERSION", "README.rdoc", "LICENSE", "GPL", ".yardopts",
                        "{config,db,lib,set}/**/*"]

  s.required_ruby_version = ">= 2.3.0"
  s.metadata = { "card-mod" => "recaptcha" }
  s.add_runtime_dependency "card-mod-layout"
end
