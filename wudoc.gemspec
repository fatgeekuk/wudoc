Gem::Specification.new do |s|
  s.name        = 'wudoc'
  s.version     = '0.0.0'
  s.date        = '2020-09-03'
  s.summary     = "whatsUpDoc"
  s.description = "Ruby based universal documentation generator"
  s.authors     = ["Peter Morris"]
  s.email       = 'peter.r.morris@gmail.com'
  s.files       = ["lib/wudoc.rb"]
  s.homepage    = 'https://rubygems.org/gems/wudoc'
  s.license     = 'MIT'
  s.executables << 'wudoc'

  s.add_dependency 'redcarpet'
  s.add_dependency 'parser'
  s.add_dependency 'pry'
  s.add_dependency 'pry-doc'
  s.add_development_dependency 'rspec'
end