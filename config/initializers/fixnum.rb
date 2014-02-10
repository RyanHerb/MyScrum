class Fixnum
  
  def blank?
    !!(self.nil? || self.to_s.match(/^(\s?)+$/))    
  end
  
  def empty?
    !!(self.nil? || self == 0)
  end
  
  def rotate(places, max)
    (self + places) % max
  end
end