class Regexp
  
  class << self
  
    def email_pattern
      email = / ^                               # Once upon a time...
                [\w\d\$\/!#%&'*+=?^`{|}~-]+     # The local part can start with these characters
                ( \.                            # It may contain periods, but not at the begin or at the end, and not repeating ones
                  [\w\d\$\/!#%&'*+=?^`{|}~-]+   # After a period there should be one or more other characters
                )*                              # .bla.nextbla.morebla
                @                               # Here comes the domain part
                [\da-zA-Z]+                     # The domain should start with a letter or number...
                ( [.-]                          # ... it may contain periods or dashes
                  [\da-zA-Z]+                   # ... between alphanumeric characters
                )*
                $                               # The End
              /x
    end
    
    def url_pattern
      %r{^(https?://)?([\da-zA-Z-]\.)+[A-Za-z]{2,6}(/\S*)?$}
    end
  
    def ip_pattern
      /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
    end
  
    def html_tag_pattern
      /^<([a-z]+)([^<]+)*(?:>(.*)<\/\1>|\s+\/>)$/
    end
  
    def password_pattern
      /^.{6,18}$/
    end
  end  
end