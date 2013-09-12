module JwAlipay
  class Response
    include Sign

    attr_reader :fields, :data, :error

    def initialize(res, options = {})
      fields = Hash[res.split('&').map{ |f| f.split('=') }].symbolize_keys
      sign, sort = fields[:sign], options[:sort].nil? ? true : options[:sort]
      if sign and verify_sign(fields, sort)
        data = fields[options[:data_name]]
        @fields = fields
        @data = data ? parse_xml_data(data, options[:data_root]) : nil
      elsif sign
        @error = {:msg => :sign_error, :detail => 'sign error'}
      else
        err = fields[options[:error_name]]
        @error = err ? parse_xml_data(err, options[:error_root]) : nil
      end
    end

    def parse_xml_data(xml, root = nil)
      res = Hash.from_xml(CGI.unescape(xml)).symbolize_keys
      (root ? res[root] : res).symbolize_keys
    end
  end
end
