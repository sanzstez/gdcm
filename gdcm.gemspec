# -*- encoding: utf-8 -*-
$:.unshift File.expand_path('../lib', __FILE__)

require 'gdcm/version'

Gem::Specification.new do |s|
  s.name        = 'gdcm'
  s.version     = GDCM.version
  s.platform    = Gem::Platform::RUBY
  s.description = s.summary = 'Ruby adapter for GDCM tools for DICOM medical files.'
  s.requirements << 'You must have GDCM tools installed'
  s.licenses    = ['MIT']

  s.authors     = ['sanzstez']
  s.email       = ['sanzstez@gmail.com']
  s.homepage    = 'https://github.com/sanzstez/gdcm'

  s.files        = Dir['VERSION', 'MIT-LICENSE', 'Rakefile', 'lib/**/*']
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 2.0'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'posix-spawn' unless RUBY_PLATFORM == 'java'
  s.add_development_dependency 'webmock'
end
