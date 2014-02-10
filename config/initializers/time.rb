class Time
  def short
    self.strftime('%d %b %Y')
  end
  def uk
    self.strftime('%d/%m/%Y')
  end
  def uk_datetime
    self.strftime('%d/%m/%Y  %H:%M')    
  end
  def uk_datetime_dash
    self.strftime('%d-%m-%Y - %H:%M')
  end
  def short_datetime
    self.strftime('%d %b %Y at %H:%M')  
  end
  def long
    self.strftime('%d %B %Y')
  end
  
  def iso8601
    self.strftime('%Y-%m-%d')
  end

  def to_datetime
    # Convert seconds + microseconds into a fractional number of seconds
    seconds = sec + Rational(usec, 10**6)

    # Convert a UTC offset measured in minutes to one measured in a
    # fraction of a day.
    offset = Rational(utc_offset, 60 * 60 * 24)
    DateTime.new(year, month, day, hour, min, seconds, offset)
  end

end