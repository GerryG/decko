# -*- encoding : utf-8 -*-

require "../../../versioning"

Gem::Specification.new do |s|
  s.name = "card-mod-tinymce_editor"
  s.version = Versioning.simple

  s.authors = ["Ethan McCutchen", "Philipp Kühl", "Gerry Gleason"]
  s.email = ["info@decko.org"]

  s.summary       = "Calendar editor"
  s.description   = ""
  s.homepage      = "http://decko.org"
  s.licenses      = ["GPL-2.0", "GPL-3.0"]

  s.files         = Dir["{db,lib,public,set}/**/*"]

  s.required_ruby_version = ">= 2.5"
  s.add_runtime_dependency "card-mod-edit", Versioning.simple
end
