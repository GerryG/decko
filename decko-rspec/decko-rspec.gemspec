# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.gem "decko-rspec" do |s, _d|
  s.summary = "rspec support for decko monkeys"
  s.description = ""

  [
    ["i18n-tasks", "~> 0.9.5"], # See if I18n keys are missing or unused
    ["minitest"],
    ["nokogumbo"],
    ["rails-controller-testing"],
    ["rr"],
    ["rspec-html-matchers", "0.9.1"],
    ["rspec"],
    ["rspec-rails", "~> 4.0.0.beta2"],   # behavior-driven-development suite
    ["rubocop-rspec"],
    ["spork", ">=0.9"]
  ].each do |dep|
    s.add_runtime_dependency(*dep)
  end
end