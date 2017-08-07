module YlPay
  require 'base64'

  class Utils
    def self.param_sign(params)
      "Version=#{params[:version]}&MerchantId=#{params[:mch_id]}&MerchOrderId=#{params[:order_id]}&"\
      "Amount=#{params[:amount]}&OrderDesc=#{params[:order_desc]}&TradeTime=#{params[:trade_time]}&ExpTime=#{params[:exp_time]}&"\
      "NotifyUrl=#{params[:notify_url]}&ReturnUrl=#{params[:return_url]}&ExtData=#{params[:ext_data]}&"\
      "MiscData=#{params[:misc_data]}&NotifyFlag=#{params[:notify_flag]}&ClientIp=#{params[:client_ip]}"
    end

    def self.back_sign(params)
      "Version=#{params['Version']}&MerchantId=#{params['MerchantId']}&MerchOrderId=#{params['MerchOrderId']}&"\
      "Amount=#{params['Amount']}&TradeTime=#{params['TradeTime']}&OrderId=#{params['OrderId']}&VerifyTime=#{params['VerifyTime']}"
    end

    # 提交参数中包含中文的需要做base64转码
    def self.uri_params(params)
      container = [:order_desc, :ext_data, :misc_data]
      new_params = params.collect do |param|
        if container.include? param[0]
          param[1] = Base64.strict_encode64(param[1])
        end
        param
      end
      new_params = Hash[new_params]
      new_params[:notify_url] = CGI.escape(new_params[:notify_url]) if new_params.key?(:notify_url)
      new_params[:return_url] = CGI.escape(new_params[:return_url]) if new_params.key?(:return_url)
      param_sign new_params
    end

    # 商户订单号
    def self.mch_order_id
      t = Time.now
      order_id = t.strftime('%Y%m%d%H%M%S') + t.nsec.to_s
      order_id.ljust(24, rand(10).to_s)
    end
  end
end

# def self.param_sign_auto(params)
# return_str = ''
# params.each { |k, v| return_str << "#{k.to_s.split('_').collect(&:capitalize).join}=#{v}&" }
# return_str.split.join(' ').chop
# end