module YlPay
  class Sign
    def self.sign(string)
      rsa = OpenSSL::PKey::RSA.new(File.read(YlPay.mch_rsa_private_key))
      Base64.strict_encode64(rsa.sign(OpenSSL::Digest::MD5.new, string))
    end

    def self.verify?(string, sign)
      rsa = OpenSSL::PKey::RSA.new(File.read(YlPay.payeco_rsa_public_key))
      rsa.verify(OpenSSL::Digest::MD5.new, Base64.strict_decode64(sign), string)
    end
  end
end