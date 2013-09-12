require "jw_alipay/engine"

module JwAlipay
  autoload :Helper, 'jw_alipay/helper'
  autoload :Response, 'jw_alipay/response'
  autoload :Sign, 'jw_alipay/sign'

  class << self
    def seq
      ("%10.6f" % Time.now.to_f).to_s.gsub('.', '')
    end
  end
end
