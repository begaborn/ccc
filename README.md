# ccc
CCC (Combined CryptoCurrency exchanges API) is a gem library that matches up lots of different interfaces for each cryptocurrency exchange's APIs, and thereby it makes the APIs easier to use.

For instance, say you use each different exchange's APIs. You must create one module in accordance with "Zaif" exchange's interface and one module in accordance with "Bitbank" exchange's interface. You have to build the similar module twice. It's a very complex and tiresome business.

But if you add this gem, you can call up each API simply on the same interface.

# Support
- [Bitbank API](https://docs.bitbank.cc)
- [Korbit API](https://apidocs.korbit.co.kr)
- [Zaif API](https://corp.zaif.jp/api-docs/)

Support exchanges can be added at a later date.

# Installation
### Set Environment Variable For API KEY
```sh
export BITBANK_API_KEY=xxxxx
export BITBANK_API_SECRET=xxxx
export KORBIT_API_KEY=xxxxx
export KORBIT_API_SECRET=xxxx
export ZAIF_API_KEY=xxxxx
export ZAIF_API_SECRET=xxxx
```

### Install the Gem Library
#### Donwload Source Code
```sh
git@github.com:begaborn/ccc.git
```

or 

#### Add this line to Gemfile:
```
gem 'ccc', github: 'begaborn/ccc'
```

```
bundle install
```

# Example
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