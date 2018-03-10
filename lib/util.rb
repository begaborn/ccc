class Float
  def round_down(digit)
    f = self.to_s.to_d.floor(digit).to_f
    digit > 0 ? f : f.to_i
  end
end

class Fixnum
  def round_down(digit)
    self.to_s.to_d.floor(digit).to_i
  end
end