require 'faraday'
require 'json'
require 'active_support/core_ext/hash/conversions'

module YlPay
  class Service
    PAY_URI = 'https://testmobile.payeco.com/ppi/merchant/itf.do'
    H5_URI = 'https://testmobile.payeco.com/ppi/h5/plugin/itf.do'

    INVOKE_ORDER_REQUIRED_FIELDS = [:amount, :order_desc, :client_ip]
    def self.generate_order_url(params, options = {})
      params = {
        version: YlPay::VERSION,
        mch_id: options.delete(:mch_id) || YlPay.mch_id,
        notify_url: options.delete(:notify_url) || YlPay.notify_url,
        trade_code: options.delete(:trade_code) || 'PayOrder',
        ext_data: options.delete(:ext_data) || 'H5测试',
        exp_time: options.delete(:exp_time) || '',
        notify_flag: options.delete(:notify_flag) || '0',
        order_id: options.delete(:order_id) || YlPay::Utils.mch_order_id,
        misc_data: options.delete(:misc_data) || '13922897656|0||张三|440121197511140912|62220040001154868428||PAYECO20151028543445||2|',
      }.merge(params)
      check_required_options(params, INVOKE_ORDER_REQUIRED_FIELDS)
      result = YlPay::Result.new(Hash.from_xml(invoke_remote(PAY_URI, make_payload(params))))
      return JSON(result.failure_data) unless result.success?
      back_sign = check_back_sign(result.body)
      return JSON({code: 'E102', data: '签名验证失败'}) unless back_sign
      pay_url(back_sign[0] + "&Sign=#{back_sign[1]}")
    end

    # 根据返回回来的参数，生成去支付页面的url
    def self.pay_url(params, options = {pay_way: 'h5_pay_url'})
      pay_way = options.delete(:pay_way)
      send(pay_way, params)
    end

    def self.h5_pay_url(params)
      H5_URI + '?tradeId=h5Init' + "&#{params}"
    end

    class << self
      private

      def check_required_options(options, names)
        return unless YlPay.debug_mode?

        names.each do |name|
          warn("YlPay Warn: missing required option: #{name}") unless options.has_key?(name)
        end
      end

      def make_payload(params)
        trade_code = params.delete(:trade_code)
        sign_params = YlPay::Utils.param_sign(params)
        rsa_sign = YlPay::Sign.sign(sign_params)
        "TradeCode=#{trade_code}&" + YlPay::Utils.uri_params(params) + "&Sign=#{rsa_sign}"
      end

      def invoke_remote(url, payload, options = {})
        remote_url = url + "?#{payload}"
        Faraday.get(remote_url).body
      end

      def check_back_sign(data)
        sign = data.delete('Sign')
        back_sign = YlPay::Utils.back_sign(data)
        YlPay::Sign.verify?(back_sign, sign) ? [back_sign, sign]  : false
      end
    end
  end
end