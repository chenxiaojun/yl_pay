易联支付 Ruby SDK Gem

## Installation

Add this line to your application's Gemfile:

    gem 'yl_pay'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install yl_pay

## Usage
### H5 Payment

### Config

Create `config/initializers/yl_pay.rb` and put following configurations into it.

```ruby
# required
YlPay.payeco_url = '' # 易联接口URL
YlPay.mch_rsa_private_key = '' # 商户私钥路径
YlPay.payeco_rsa_public_key = '' # 易联公钥路径 
YlPay.merchant_id = '' # 商户ID
YlPay.notify_url = '' # 通知服务器地址
YlPay.return_url = '' # 重定向地址

`YlPay::Service.generate_order_url params` will create an payment request and return a pay url.

# required fields
params = {
  amount: '',
  order_desc: '',
  client_ip: '',
  merch_order_id: '', # 商户订单ID
  trade_time: '' # 交易时间的格式 time.strftime('%Y%m%d%H%M%S')
}

# optional fields 
params = {
  ext_data: '', # 商户自定义传递的参数, 异步通知会返回回去
  misc_data: '' # 默认的银行卡参数
}

# call generate_order_url
pay_url = YlPay::Service.generate_order_url params

# verify notify or return sign
YlPay::Service.check_notify_sign(params)
```



## Contributing

1. Fork it ( https://github.com/chenxiaojun/yl_pay/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request