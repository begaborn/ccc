class Float
  def round_down(digit)
    f = self.to_s.to_d.floor(digit).to_f
    digit > 0 ? f : f.to_i
  end

  def flatten(digit)
    round_down(digit - self.to_i.to_s.size)
  end

  def trim(unit)
    after_point_digit =
      if unit.is_a? Float
        (unit.to_s.split(".")[1].length) + 1
      else
        1
      end

    factor = 10 ** after_point_digit
    (self * factor).to_i / (unit * factor).to_i * unit
  end
end

class Integer
  def round_down(digit)
    self.to_s.to_d.floor(digit).to_i
  end

  def flatten(digit)
    round_down(digit - self.to_s.size)
  end

  def prefix(digit)
    self / (10 ** (self.to_s.size - digit))
  end

  def trim(unit)
    after_point_digit =
      if unit.is_a? Float
        unit.to_s.split(".")[1].length
      else
        0
      end

    factor = 10 ** after_point_digit
    (self * factor).to_i / (unit * factor).to_i * unit
  end
end