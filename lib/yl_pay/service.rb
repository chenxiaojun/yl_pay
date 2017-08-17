require 'faraday'
require 'json'
require 'active_support/core_ext/hash/conversions'

module YlPay
  class Service
    H5_URI = '/ppi/h5/plugin/itf.do'.freeze
    AUTHORIZE_URI = '/ppi/merchant/itf.do'.freeze

    INVOKE_ORDER_REQUIRED_FIELDS = [:amount, :order_desc, :client_ip, :merch_order_id, :trade_time]
    def self.generate_order_url(params, options = {})
      check_required_options(params, INVOKE_ORDER_REQUIRED_FIELDS)
      params = set_params(params, options)
      result = YlPay::Result.new(Hash.from_xml(invoke_remote(YlPay.payeco_url + AUTHORIZE_URI, make_payload(params))))
      JSON(parse_result(result))
    end

    def self.parse_result(result)
      return result.failure unless result.success?

      back_sign = check_back_sign(result.body)
      return result.sign_error unless back_sign

      url = pay_url(back_sign[0] + "&Sign=#{back_sign[1]}")
      result.success(url)
    end

    # 根据返回回来的参数，生成去支付页面的url
    def self.pay_url(params, options = { pay_way: 'h5_pay_url' })
      pay_way = options.delete(:pay_way)
      send(pay_way, params)
    end

    def self.h5_pay_url(params)
      YlPay.payeco_url + H5_URI + '?tradeId=h5Init' + "&#{params}"
    end

    def self.check_notify_sign(params)
      sign = params.delete('Sign')
      notify_sign = YlPay::Utils.notify_sign(params)
      YlPay::Sign.verify?(notify_sign, sign)
    end

    class << self
      private

      def set_params(params, options)
        {
          version: YlPay.version,
          merchant_id: options.delete(:merchant_id) || YlPay.merchant_id,
          notify_url: options.delete(:notify_url) || YlPay.notify_url,
          return_url: options.delete(:return_url) || YlPay.return_url,
          trade_code: options.delete(:trade_code) || 'PayOrder',
          exp_time: options.delete(:exp_time) || '',
          notify_flag: options.delete(:notify_flag) || '0'
        }.merge(params)
      end

      def check_required_options(options, names)
        return unless YlPay.debug_mode?

        names.each do |name|
          warn("YlPay Warn: missing required option: #{name}") unless options.key?(name)
        end
      end

      def make_payload(params)
        trade_code = params.delete(:trade_code)
        sign_params = YlPay::Utils.param_sign(params)
        rsa_sign = YlPay::Sign.sign(sign_params)
        "TradeCode=#{trade_code}&" + YlPay::Utils.uri_params(params) + "&Sign=#{rsa_sign}"
      end

      def invoke_remote(url, payload)
        remote_url = url + "?#{payload}"
        Faraday.get(remote_url).body
      end

      def check_back_sign(data)
        sign = data.delete('Sign')
        back_sign = YlPay::Utils.back_sign(data)
        YlPay::Sign.verify?(back_sign, sign) ? [back_sign, sign] : false
      end
    end
  end
end
