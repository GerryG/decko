# -*- encoding : utf-8 -*-

require "../decko_gem"

Gem::Specification.new do |s|
  s.class.include DeckoGem
  s.shared

  s.name = "card"
  s.version = s.card_version

  s.summary = "a simple engine for emergent data structures"
  s.description =
    "Cards are wiki-inspired data atoms." \
    'Card "Sharks" use links, nests, types, patterned names, queries, views, ' \
    "events, and rules to create rich structures."

  s.files = Dir["VERSION", "README.rdoc", "LICENSE", "GPL", ".yardopts",
                "{config,bin,script,db,lib,mod,tmpsets}/**/*"]

  s.bindir        = "bin"
  s.executables   = ["card"]

  s.require_paths = ["lib"]

  [
    ["cardname",            s.decko_version],

    ["haml",                        "~> 5.0"], # markup language used in view API
    ["jwt",                         "~> 2.2"], # used in token.rb
    ["uuid",                        "~> 2.3"], # universally unique identifier.
                                               # used in temporary names
    ["colorize",                    "~> 0.8"], # livelier cli outputs
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # MOVE TO MODS?

    # assets (JavaScript, CSS, etc)
    ["coderay",                     "~> 1.1"],
    ["sassc",                       "~> 2.0"],
    ["coffee-script",               "~> 2.4"],
    ["uglifier",                    "~> 3.2"],
    ["sprockets",                   "~> 3.7"], # sprockets 4 requires new configuration

    # pagination
    ["kaminari",                    "~> 1.0"],
    ["bootstrap4-kaminari-views",   "~> 1.0"],

    # other
    ["diff-lcs",                    "~> 1.3"], # content diffs in histories
    ["delayed_job_active_record",   "~> 4.1"],
    ["activerecord-import",         "~> 1.0"],

    ["rake",                     "<= 12.3.0"],
    ["rails",                         "~> 6"]
  ].each do |dep|
    s.add_runtime_dependency(*dep)
  end
end
