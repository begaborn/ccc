# ccc
ccc is a wrapper interface of Crypt Currency Exchanges API

# Support
- [Bitbank API](https://docs.bitbank.cc)
- [Korbit API](https://apidocs.korbit.co.kr)
- [Zaif API](https://corp.zaif.jp/api-docs/)

## Installation
#### Set Environment Variable For API KEY
```sh
export BITBANK_API_KEY=xxxxx
export BITBANK_API_SECRET=xxxx
export KORBIT_API_KEY=xxxxx
export KORBIT_API_SECRET=xxxx
export ZAIF_API_KEY=xxxxx
export ZAIF_API_SECRET=xxxx
```

#### Donwload Source Code
```sh
git@github.com:begaborn/ccc.git
```

#### Install Gem
```
bundle install
```

## Example
```ruby
btc = Bitbank.btc

# Show the price for Bitbank
btc.price

# Show my orders for Bitbank
btc.my_orders

# Show my balance for Bitbank
btc.balance

# API For Korbit
btc = Korbit.btc
btc.price
btc.my_orders
btc.balance
```

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).