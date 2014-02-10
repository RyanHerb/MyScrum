require 'sequel/extensions/inflector'

class String

  def blank?
    !!(self.nil? || self !~ /^.*\S+.*$/m)
  end

  def variablize
    self.downcase.gsub(/\s+/, '_')
  end

  def sluggify
    slug = URI.decode(self)
    slug.gsub(/([^\w\s-])+/,'').gsub(/(\W)+/,'-').gsub(/^-|-$/,'').downcase
  end

  def truncate(options = {})
    omission = options[:omission] || "..."
    length   = options[:length]   || 30
    (self.length > length ? self[0...length] + omission : self).to_s
  end

  def truncate_words(options = {})
    omission = options[:omission] || "..."
    length   = options[:length]   || 20
    summary = self.split(/\s+/)
    summary[0..length-1].join(' ') + (summary.length <= length ? '' : omission)
  end

  def to_keywords
    self.split(/(?:\s*,\s*)+|\s+/)
  end

  def fast_escape_html
    self.gsub(/\&/,'&amp;').gsub(/\"/,'&quot;').gsub(/>/,'&gt;').gsub(/</,'&lt;')
  end
  
  def nib
    blank? ? nil : self
  end
  
end