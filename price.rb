$:.unshift(File.dirname(File.expand_path(__FILE__)) + '/lib')
require 'ccc'

markets = (ARGV[0] || 'bitflyer,zaif').split(',')
puts 'PRICE(JPY)'
puts '------------------------------------------------------------------------'
loop do |count|
  info = ''
  Ccc.markets_with_currencies(markets).each do |market, currencies|
    info += "|#{market.upcase}|"
    currencies.each do |currency|
      currency.reload
      info += "#{currency.currency_code.underscore}:#{currency.price}  "
    end
    info += '  '
  end
  info += "|"
  printf info
  printf "\e[#{info.size}D"
  STDOUT.flush
  sleep 1
end
