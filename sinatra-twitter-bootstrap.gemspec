Gem::Specification.new do |s|
  s.name = "sinatra-twitter-bootstrap"
  s.version = "2.3.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michal Fojtik"]
  s.date = "2012-12-11"
  s.description = "Bootstrap Sinatra extension"
  s.email = "mi@mifo.sk"
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = [
    "lib/sinatra/twitter-bootstrap.rb",
    "lib/sinatra/helpers/haml_helpers.rb"
  ]
  s.homepage = "http://github.com/mifo/sinatra-twitter-bootstrap"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "Bootstrap Sinatra extension with HAML helpers"
end
