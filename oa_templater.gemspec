Gem::Specification.new do |s|
  s.name        = 'oa_templater'
  s.version     = '0.1.0'
  s.date        = '2014-06-05'
  s.summary     = "Hola!"
  s.description = "A gem to parse out elements of Japanese Patent Office Actions"
  s.authors     = ["James Rubingh"]
  s.email       = 'james@wrive.com'
  s.files       = ["lib/oa_templater.rb",
                   "lib/citations.yml"]
  s.homepage    = 'https://github.com/ephesus/oa_templater'
  s.license     = 'GPLv2+'
  s.add_runtime_dependency 'iconv', '~> 1'
  s.add_runtime_dependency 'docx_templater', '~> 0.2', '>= 0.2.3'
end
