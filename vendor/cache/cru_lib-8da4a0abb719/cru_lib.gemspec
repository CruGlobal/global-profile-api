# -*- encoding: utf-8 -*-
# stub: cru_lib 0.0.6 ruby lib

Gem::Specification.new do |s|
  s.name = "cru_lib"
  s.version = "0.0.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Josh Starcher"]
  s.date = "2017-01-26"
  s.description = "Collection of common ruby logic used by a number of Cru apps"
  s.email = ["josh.starcher@gmail.com"]
  s.files = [".gitignore", "Gemfile", "LICENSE.txt", "README.md", "Rakefile", "cru_lib.gemspec", "lib/cru_lib.rb", "lib/cru_lib/access_token.rb", "lib/cru_lib/access_token_protected_concern.rb", "lib/cru_lib/access_token_serializer.rb", "lib/cru_lib/api_error.rb", "lib/cru_lib/api_error_serializer.rb", "lib/cru_lib/async.rb", "lib/cru_lib/global_registry_methods.rb", "lib/cru_lib/global_registry_relationship_methods.rb", "lib/cru_lib/version.rb", "spec/shared_examples_for_global_registry_models.rb"]
  s.homepage = ""
  s.licenses = ["MIT"]
  s.rubygems_version = "2.5.1"
  s.summary = "Misc libraries for Cru"
  s.test_files = ["spec/shared_examples_for_global_registry_models.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<global_registry>, [">= 0"])
      s.add_runtime_dependency(%q<active_model_serializers>, [">= 0"])
      s.add_runtime_dependency(%q<redis>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.6"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<global_registry>, [">= 0"])
      s.add_dependency(%q<active_model_serializers>, [">= 0"])
      s.add_dependency(%q<redis>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.6"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<global_registry>, [">= 0"])
    s.add_dependency(%q<active_model_serializers>, [">= 0"])
    s.add_dependency(%q<redis>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.6"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
