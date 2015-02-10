require File.dirname(__FILE__) + '/lib/version'

Gem::Specification.new do |s|
  s.name        = 'oa_templater'
  s.version     = OaTemplater::VERSION
  s.date        = '2014-06-05'
  s.summary     = 'JPO OA Templater'
  s.description = "A gem to parse out and \"translate\" elements of Japanese Patent Office Actions"
  s.authors     = ['James Rubingh']
  s.email       = 'james@wrive.com'
  s.files       = `git ls-files`.split($INPUT_RECORD_SEPARATOR).grep(%r{^lib/})
  s.require_paths = ['lib']
  s.homepage    = 'https://github.com/ephesus/oa_templater'
  s.license     = 'GPLv2+'
  s.add_runtime_dependency 'charlock_holmes', '~> 0'
  s.add_runtime_dependency 'docx_templater', '~> 0.2', '>= 0.2.3'
  s.add_runtime_dependency 'kakasi', '~> 1.0', '>= 1.0.0'

end
