module YlPay
  class Result
    attr_accessor :code, :msg, :body

    def initialize(result)
      @code = result['response']['head']['retCode']
      @msg = result['response']['head']['retMsg']
      @body = result['response']['body']
    end

    def success?
      code.eql?('0000')
    end

    def failure
      { code: code, msg: msg }
    end
  end
end