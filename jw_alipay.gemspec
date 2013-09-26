$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "jw_alipay/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "jw_alipay"
  s.version     = JwAlipay::VERSION
  s.authors     = ["fz"]
  s.email       = ["zhu.fang@joowing.com"]
  s.homepage    = "https://github.com/fangzhu19880123/jw_alipay"
  s.summary     = "A gem for alipay"
  s.description = "A gem for alipay, contains mobile payment"
  s.license     = 'MIT'

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  # s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.8"
  s.add_dependency "rest-client"

  s.add_development_dependency "sqlite3"
end
