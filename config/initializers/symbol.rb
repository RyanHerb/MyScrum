class Symbol
  
  # :input.tag :name => 'address', :value => 'Foo Road'
  def tag(options={})
    option_string = (' ' + options.to_html_options).sub(/\s+$/, '')
    "<#{self.to_s}#{option_string} />"
  end
  
  # :div.wrap "Hello", :id => "userbox", :class => "box"
  # :div.wrap(:id => "userbox", :class => "box"){ "Hello" }
  #
  # If you give a content as block and as parameter too, then the parameter
  # will be the default value (in case of the block is empty)
  def wrap(content=nil, options={}, &block)
    (options = content; content = nil) if content.is_a? Hash
    content = yield || content if block
    option_string = (' ' + options.to_html_options).sub(/\s+$/, '')
    "<#{self.to_s}#{option_string}>#{content.to_s}</#{self.to_s}>"
  end
end