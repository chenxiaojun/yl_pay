module YlPay
  require 'uri'
  require 'base64'
  require 'active_support/core_ext/string'

  class Utils
    PARAM_SIGN_FIELD = %w(version merchant_id merch_order_id amount order_desc trade_time exp_time notify_url
                          return_url ext_data misc_data notify_flag client_ip)
    NOTIFY_SIGN_FIELD = %w(version merchant_id merch_order_id amount ext_data order_id status pay_time settle_date)
    BACK_SIGN_FIELD = %w(version merchant_id merch_order_id amount trade_time order_id verify_time)

    def self.param_sign(params)
      hash_params = params_sign_to_hash(params, PARAM_SIGN_FIELD)
      sign_uri hash_params
    end

    def self.back_sign(params)
      hash_params = params_to_hash(params, BACK_SIGN_FIELD)
      sign_uri hash_params
    end

    def self.notify_sign(params)
      hash_params = params_to_hash(params, NOTIFY_SIGN_FIELD)
      sign_uri hash_params
    end

    def self.sign_uri(hash)
      string_to_uri(stringify_keys(hash))
    end

    # 提交参数中包含中文的需要做base64转码, 对url进行urlencode处理
    def self.uri_params(params)
      new_params = param_base64_field(params)
      new_params = Hash[new_params]
      new_params[:notify_url] = CGI.escape(new_params[:notify_url]) if new_params.key?(:notify_url)
      new_params[:return_url] = CGI.escape(new_params[:return_url]) if new_params.key?(:return_url)
      param_sign new_params
    end

    PARAM_BASE64_FIELD = [:order_desc, :ext_data, :misc_data]
    def self.param_base64_field(params)
      params.collect do |param|
        if PARAM_BASE64_FIELD.include? param[0]
          param[1] = Base64.strict_encode64(param[1])
        end
        param
      end
    end

    # hash的键需要大写, 里面获取值参数也是大写 params['A': 'b']
    def self.params_to_hash(params, target_params)
      target_params.collect!(&:camelize)
      hash = {}
      target_params.collect do |k|
        hash.merge!("#{k}": params[k])
      end
      hash
    end

    # 针对param_sign hash的键大写，里面获取值参数小写 params[:A: 'b']
    def self.params_sign_to_hash(params, target_params)
      hash = {}
      target_params.collect do |k|
        k1 = k.camelize
        hash.merge!("#{k1}": params[k.to_sym])
      end
      hash
    end

    def self.string_to_uri(params)
      params.map{|entry| entry * '='} * '&'
    end

    def self.stringify_keys(hash)
      new_hash = {}
      hash.each do |key, value|
        new_hash[(key.to_s rescue key) || key] = value.to_s
      end
      new_hash
    end
  end
end
