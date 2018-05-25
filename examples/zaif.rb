$:.unshift(File.dirname(File.expand_path(__FILE__)) + '/../lib')
require 'pry-byebug'
require 'ccc'

Ccc.configure do |config|
  config.yml_filename = File.dirname(File.expand_path(__FILE__)) + '/ccc.yml'
end

Zaif.currencies.each do |c|
  currency = Zaif.send(c)
  puts '-----------------------------------'
  puts "client = #{currency.client}"
  puts "config = #{currency.conf}"
  puts "currency_code = #{currency.currency_code}"
  puts "default_pair = #{currency.default_pair}"
  puts "currency_pair = #{currency.currency_pair}"
  puts "opening_price = #{currency.opening_price}"
  puts "closing_price = #{currency.closing_price}"
  puts "high_price = #{currency.high_price}"
  puts "low_price = #{currency.low_price}"
  puts "bab_rate = #{currency.bab_rate}"
  puts "vpin = #{currency.vpin}"
  puts "buy_rate = #{currency.latest_buy_rate}"
  puts "sell_rate = #{currency.latest_sell_rate}"
  puts "price = #{currency.price}"
  puts "volume = #{currency.volume24h}"
  currency.reload
  puts "balance = #{currency.balance}"
  puts "locked_balance = #{currency.locked_balance}"
  puts "available_balance = #{currency.available_balance}"
  puts "balance_pair = #{currency.balance_pair}"
  puts "locked_balance_pair = #{currency.locked_balance_pair}"
  puts "available_balance_pair = #{currency.available_balance_pair}"
  puts "to_pair = #{currency.to_pair}"
  puts "maker fee = #{currency.maker_fee}"
  puts "taker fee = #{currency.taker_fee}"
  puts "withdrawal fee = #{currency.withdrawal_fee}"
  puts "orderable_amount = #{currency.orderable_amount}"
  puts "sellable_amount = #{currency.sellable_amount}"
  puts "buyable_amount = #{currency.buyable_amount}"
  puts "my_orders = #{currency.my_orders}"
  puts "vwap = #{currency.vwap24h}"
  puts "board = #{currency.depth}"
  puts "mid_price = #{currency.mid_price}"
  puts "asks = #{currency.asks}"
  puts "bids = #{currency.bids}"
  puts "best_ask = #{currency.best_ask}"
  puts "best_bid = #{currency.best_bid}"
  puts ''
  sleep 1
end
