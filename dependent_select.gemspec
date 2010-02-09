# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dependent_select}
  s.version = "0.7.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Enrique Garcia Cota (egarcia)"]
  s.date = %q{2009-08-10}
  s.description = %q{dependent_select: a select that depends on other field and updates itself using js}
  s.email = %q{egarcia@splendeo.es}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    "init.rb",
    "lib/dependent_select.rb",
    "lib/dependent_select/dependent_select.rb",
    "lib/dependent_select/form_helpers.rb",
    "lib/dependent_select/includes_helper.rb",
    "public/javascripts/dependent_select/dependent_select.js"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/splendeo/dependent_select}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{generates a select with some js code that updates if if another field is modified.}
  s.test_files = [ ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
