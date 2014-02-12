module GeneralUser

  require 'digest/sha1'
  
  attr_accessor :password, :password_confirmation, :auth_with_cookie

  # ===============
  # = Validations =
  # ===============

  def validate
    validates_password
    validates_presence :email, :message => 'Email address must not be blank'
    validates_presence :username, :message => 'Username must not be blank'
    validates_unique :username
    validates_unique :email
    validates_format Regexp.email_pattern, :email, :message => 'Email address is not valid'
    validates_presence :first_name, :message => 'First name cannot be blank'
    validates_presence :last_name, :message => 'Last name cannot be blank'
  end

  def validates_password
    if new?
      if password.blank?
        errors.add(:password, "your password cannot be blank")
      elsif password != password_confirmation
        errors.add(:password, "your password does not match confirmation")
      end
    else      
      unless password.blank?
        if password != password_confirmation
          errors.add(:password, "your password does not match confirmation")
        end
      end
    end
  end
  
  # =========
  # = Hooks =
  # =========
  
  def before_save
    super
    set_password
  end

  def set_password
    unless password.blank?
      self.hashed_password = Digest::SHA1.hexdigest(password)
    end
  end
  
  # ====================
  # = Instance methods =
  # ====================


  def generate_auth_token
    self.update(:auth_token => Digest::SHA1.hexdigest("#{Time.now.to_f}#{self.email}"))
  end
    
  def name
    "#{first_name} #{last_name}".strip
  end

  # =================
  # = Class Methods =
  # =================  

  module ClassMethods
    
    def auth_with_token(t)
      if u = first(:auth_token => t)
        u.update(:auth_token => nil)
      end
    end

    def auth_with_password(params)
      u = first(["email = ?", params[:email]])
      if u && !u.hashed_password.blank? && u.hashed_password == Digest::SHA1.hexdigest(params[:password])
        if u.respond_to?('save_login!')
          u.save_login!
        end
        u
      else
        false
      end
    end  
  
  end
    
end
