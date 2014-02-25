class Admin < Sequel::Model
  include GeneralUser
  extend GeneralUser::ClassMethods


# =========
# = Hooks =
# =========
  
  def save_login
    # Called from auth helpers
    self.last_login_at = self.current_login_at
    self.last_login_ip = self.current_login_ip
    # TODO find out how we can take remote ip
    # self.current_login_ip = env['REMOTE_ADDR'] 
    self.current_login_at = Time.now
    self.number_of_logins = self.number_of_logins + 1
  end
  
  def save_login!
    save_login
    save :validate => false
  end
  
# =================
# = Class methods =
# =================

  class << self

    def authenticate(user, pw)
      a = Admin.first(["email = ?", user])
      if a && a.hashed_password == Digest::SHA1.hexdigest(pw)
        a
      else
        false
      end
    end

    def find_or_new(p) 
      Admin.find(:email => p[:email]) || Admin.new(p)
    end

  end 

end
