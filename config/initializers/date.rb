class Date
  def short
    self.strftime('%d %b %Y')
  end
  def long
    self.strftime('%d %B %Y')
  end
  def uk
    self.strftime('%d/%m/%Y')
  end
  def uk_date_dash
    self.strftime('%d-%m-%Y')
  end  
  def monthyear
    self.strftime('%b-%Y')
  end
  def iso8601
    self.strftime('%Y-%m-%d')
  end
  def daydatemonth
    self.strftime('%a %d %b')
  end
  # def bloody_monday
  #    self.day -= 1 until self.cwday == 1
  #  end
end