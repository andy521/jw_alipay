require 'digest/md5'
require 'cgi'

module JwAlipay
  # TODO 暂时只支持MD5方式，RSA后续添加
  module Sign
    def verify_sign(params, sort = true, sign_type = nil)
      sign, sign_type = params.delete(:sign), params.delete(:sign_type) || sign_type || 'MD5'
      _md5_sign(params, sort) == sign.downcase
    end

    def sign(params, sort = true)
      sign_type, sign = "MD5", _md5_sign(params, sort)
      _query_string(params.merge(:sign => sign))
    end

    def _md5_sign(params, sort = true)
      Digest::MD5.hexdigest(_sign_string(params, sort) + KEY)
    end

    def _sign_string(params, sort)
      params = _sort_params(params, sort)
      params.stringify_keys.collect do |s|
        unless s[0] == :notify_id
          "#{s[0]}=#{CGI.unescape(s[1])}"
        else
          "#{s[0]}=#{s[1]}"
        end
      end.join("&")
    end

    def _query_string(params)
      params.collect{ |k, v| "#{k}=#{v}" }.join("&")
    end

    # 排序
    # sort true 排序
    # sort false 不排序
    # sort Array 按数组顺序排序
    def _sort_params(params, sort)
      case
        when sort.is_a?(Array)
          then Hash[sort.map{ |key| [key, params[key]] }]
        when true
          then Hash[params.sort]
        else
          params
      end
    end
  end
end
