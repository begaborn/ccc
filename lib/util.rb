class Float
  def round_down(digit)
    self.to_s.to_d.floor(digit).to_f
  end
end