$:.unshift(File.dirname(File.expand_path(__FILE__)) + "/lib")
require 'my_bitflyer'
require 'transaction_log'


# Auto-Exchange Program for the crypto currency
# このプログラムは一旦買ったら、次売るまで仮想通貨を購入しない
# 流れ：buy -> sell -> buy -> sell...
# 買うときは残高状況を確認して一番最大買える量を買う
def conf
  @conf ||= YAML.load_file('config.yml')
end

def transaction
  @transaction ||= TransactionLog.all
end

def is_next_action_selling?(currency_obj)
  currency_code = currency_obj.currency_code
  if transaction.empty?
    conf[currency_code]['init_action'] && conf[currency_code]['init_action'] == 'SELL'
  else
    # If last action is 'buying', next action is selling
    currency_obj.is_last_action_buying?
  end
end

def desire_price_for_selling?(currency_obj)
  if transaction.empty?
    currency_obj.price > conf['init_desire_price'] * (1 + (conf['yield'] / 100))
  else
    currency_obj.price > conf['init_desire_price'] * (1 + (conf['yield'] / 100))
  end
end

def sell?(currency_obj)
  currency_obj.jpy_for_buy_orders < currency_obj.jpy_for_my_btc * (1 - (conf['yield'] / 100))
end

def buy?(currency_obj)
  currency_obj.jpy_for_sell_orders > currency_obj.jpy_for_my_btc * (1 + (conf['yield'] / 100))
end

# どれぐらい差額だったら売るか(percent)
profit_percent_btc = 10

# 購入する時、適切な価格
init_desire_price = 700000
btc = MyBitflyer.btc

binding.pry
btc.available_bids
# 最近買った時の値段
#if last_bought_price.nil?
#  price_bought_btc = init_std_price_buy_btc
#end

# 最後に行なった行動が購入処理の場合は売却処理を検討する
if is_next_action_selling?(btc)
  # 売却
  # 望んだ価格の以下になったか確認

  # 購入した時からbitcoinの価値が上がったかチェックする

  # bitcoinの残高分売却
else
  # 売却以降bitcoinの価値が下がったかチェックする
  # bitcoinの残高分売却

end

# 売却以降購入したbitcoinの平均価格




