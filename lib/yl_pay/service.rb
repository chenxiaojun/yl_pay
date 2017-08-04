require 'faraday'
require 'active_support/core_ext/hash/conversions'

module YlPay
  class Service
    PAY_URI = 'https://testmobile.payeco.com/ppi/merchant/itf.do'

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
      YlPay::Result.new(Hash.from_xml(invoke_remote(PAY_URI, make_payload(params))))
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
        p remote_url
        Faraday.get(remote_url).body
      end
    end
  end
end