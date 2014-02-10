class Integer
  # Makes 1 => 1st, 2 => 2nd, etc.
  def ordinal
    self.to_s + ( (10...20).include?(self) ? 'th' : %w{ th st nd rd th th th th th th }[self % 10])
  end
  
  def to_day_name
    case self
    when 0 
      'Monday'
    when 1 
      'Tuesday'
    when 2 
      'Wednesday'
    when 3 
      'Thursday'
    when 4 
      'Friday'
    when 5 
      'Saturday'
    when 6 
      'Sunday' 
    end
  end
end

