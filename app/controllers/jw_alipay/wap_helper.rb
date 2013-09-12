# encoding: utf-8

require 'rest-client'
module JwAlipay
  module WapHelper
    def redirect_to_wap_alipay_gateway(options = {})
      helper = JwAlipay::Helper.new(:xml_root => :auth_and_execute_req)
      token = get_token(options).tap do |token|
        yield token if block_given?
      end
      helper.add_xml_fields(:request_token => token)
      helper.add_fields(
          :service => "alipay.wap.auth.authAndExecute",  :sec_id => "MD5", :v => "2.0",
          :req_data => CGI.escape(helper.xml_string), :format => "xml"
      )

      redirect_to "http://wappaygw.alipay.com/service/rest.htm?#{helper.query_string}"
    end

    def get_token(options = {})
      helper = JwAlipay::Helper.new(:xml_root => :direct_trade_create_req)
      helper.add_xml_fields(
          :subject => options[:subject],
          :out_trade_no => options[:out_trade_no],
          :total_fee => options[:total],
          :seller_account_name => JwAlipay::EMAIL,
          :call_back_url => options[:call_back_url],
          :notify_url => options[:notify_url],
          :out_user => options[:out_user],
          :merchant_url => options[:merchant_url],
          :pay_expire => options[:pay_expire]
      )
      helper.add_fields(
          :service => "alipay.wap.trade.create.direct",  :sec_id => "MD5", :v => "2.0",
          :req_data => helper.xml_string, :req_id => JwAlipay.seq, :format => "xml"
      )

      res_string = RestClient.post("http://wappaygw.alipay.com/service/rest.htm", helper.query_string)
      res = JwAlipay::Response.new(
          res_string,
          :data_name => :res_data,
          :data_root => :direct_trade_create_res,
          :error_name => :res_error,
          :error_root => :err
      )

      raise res.error[:detail] if res.error
      res.data[:request_token]
    end

    def call_back
      logger.info "支付宝call_back，request string：#{request.query_string}"
      res = JwAlipay::Response.new(request.query_string)
      if res.fields.try{ |x| x[:result] } == 'success'
        logger.info "订单[#{res.fields.try{ |x| x[:out_trade_no] }}]支付成功，调用call_back"
        yield res.fields
      else
        logger.error "订单[#{res.data.try{ |x| x[:out_trade_no] }}]支付出现问题，#{res.error.try{ |x| x[:detail] }}"
      end
    end

    def notify
      logger.info "支付宝notify，request string：#{env['rack.request.form_vars']}"
      res = JwAlipay::Response.new(
          env['rack.request.form_vars'],
          :sort => [:service, :v, :sec_id, :notify_data],
          :data_name => :notify_data,
          :data_root => :notify
      )
      if ['TRADE_SUCCESS', 'TRADE_PENDING', 'TRADE_FINISHED'].include? res.data.try{ |x| x[:trade_status] }
        logger.info "订单[#{res.data.try{ |x| x[:out_trade_no] }}]支付成功，调用notify"
        yield res.data
      else
        logger.error "订单[#{res.data.try{ |x| x[:out_trade_no] }}]支付出现问题，status：#{res.data.try{ |x| x[:trade_status] }}，detail：#{res.error.try{ |x| x[:detail] }}"
      end
    end
  end
end