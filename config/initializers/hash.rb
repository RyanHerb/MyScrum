#========================================
# monkey patches.. keep it sane plz
#----------------------------------------

class Hash
  def symbolize_keys
    self.dup.symbolize_keys!
  end
  
  def symbolize_keys!
    self.keys.each do |k|
      unless k.is_a?(Symbol)
        self[k.to_sym] = self[k]
        self.delete(k)
      end
    end
    self
  end
  
  def stringify_keys
    self.dup.stringify_keys!
  end
  
  def stringify_keys!
    self.keys.each do |k|
      unless k.is_a?(String)
        self[k.to_s] = self[k]
        self.delete(k)
      end
    end
    self
  end
  
  # This is usable in HTML tags
  def to_html_options
    (self.map{|key, value| %(#{key.to_s}="#{value.to_s}") if value } - [nil]).join(" ")
  end
  
  def reverse_merge(other_hash)
    other_hash.merge(self)
  end

  # Destructive +reverse_merge+.
  def reverse_merge!(other_hash)
    # right wins if there is no left
    merge!( other_hash ){|key,left,right| left }
  end
  
end