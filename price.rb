$:.unshift(File.dirname(File.expand_path(__FILE__)) + '/lib')
require 'optparse'
require 'ccc'
require 'pry-byebug'
require 'color_echo'

def show(msg = '', csv = false)
  @info ||= ''
  @info += msg
  printf msg
end

def show_flush
  printf "\e[#{@info.size}D"
  STDOUT.flush
  @info = ''
end

params = ARGV.getopts('', 'markets:bitflyer,zaif,coincheck,korbit', 'currencies:btc,bch,eth', 'csv', 'count:', 'flush', 'interval:60')
target_markets = params['markets'].split(',')
target_currencies = params['currencies'].split(',')
interval = params['interval'].to_i
count = params['count'].to_i
flush = params['flush']
csv = params['csv']

`mkdir csv` unless File.exist?('csv')
puts 'DATE             |PRICE(JPY:Bitflyer,Zaif,Coincheck  KRW:Korbit)'
puts '-----------------------------------------------------------------------------------------------------'
1.step do |index|
  exit if count != 0 && index > count
  date = Time.now.strftime('%Y-%m-%d %H:%M')
  show "#{date} "

  date_str = Time.now.strftime('%Y%m%d')
  price_csv = File.open("csv/#{date_str}.csv", 'a') if csv
  price_str = "#{date}, "

  Ccc.markets_with_currencies(target_markets).each do |market, currencies|
    show "|#{market.upcase}|"
    currencies.each do |currency|
      currency_code = "#{currency.currency_code.underscore}"
      next unless target_currencies.include?(currency_code)
      before_price = currency.price
      currency.reload
      show "#{currency_code}:"
      if currency.price > before_price
        CE.once.fg :green
      elsif currency.price < before_price
        CE.once.fg :red
      end
      show "#{currency.price}  "
      price_str += "#{currency.price}, "
    end
    show '  '
  end

  if csv
    price_csv.puts price_str
    price_csv.close
  end
  show "|"

  if flush
    show_flush
  else
    printf "\n"
  end
  sleep interval
end

