class Array
  
  def count
    length
  end

  def group_by
    hsh = {}
    self.dup.each_with_index do |element, i|
      if block_given?
        key = yield element
      else
        key = i
      end
      hsh[key] ||= []
      hsh[key] << element
    end
    hsh
  end
  
  def rotate
    push shift
  end

  def to_sentence
    if self.length > 1
      self[0..-2].join(", ") + " and " + self[-1]
    elsif self.length == 1
      self[0]
    else
      ""
    end
  end
  
end

class SortedArray < Array
  attr_accessor :sortorder
end