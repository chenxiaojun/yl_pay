require 'yl_pay/service'
require 'yl_pay/version'
require 'yl_pay/sign'
require 'yl_pay/utils'
require 'yl_pay/result'
require 'openssl'

module YlPay
  @debug_mode = true

  class << self
    attr_accessor :mch_id, :notify_url, :return_url, :payeco_url, :mch_rsa_private_key, :payeco_rsa_public_key

    def debug_mode?
      @debug_mode
    end
  end
end
