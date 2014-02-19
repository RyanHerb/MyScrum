class BugReport < Sequel::Model

 def validate
    validates_presence :title, :message => 'Title must not be blank'
    validates_format URI.regexp, :url, :allow_blank => false, :message => 'URL is not valid'
    validates_presence :description, :message => 'Description must not be blank'
  end

end
