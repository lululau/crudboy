class String
  def p
    puts self
  end

  def expa
    File.expand_path(self)
  end

  def f
    expa
  end

  def as_path
    File.join(*(split(/\W/)))
  end
end
