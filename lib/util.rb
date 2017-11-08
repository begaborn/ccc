def up_rate(num)
  1 + percent(num)
end

def down_rate(num)
  1 - percent(num)
end

def percent(num)
  num / 100.to_f
end
