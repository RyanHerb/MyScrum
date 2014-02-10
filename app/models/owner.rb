class Owner < Sequel::Model
  
  # see config/initializers/user.rb
  include GeneralUser
  extend GeneralUser::ClassMethods

  # ================
  # = Associations =
  # ================

  one_to_many :properties, :class => :Property

  # ===============
  # = Validations =
  # ===============
  def validate
    # some validations in GeneralUser module
    super
    validates_unique(:username)
  end

  # =========
  # = Hooks =
  # =========

  def save_login
    # Called from auth helpers
    self.last_login_at = self.current_login_at
    self.last_login_ip = self.current_login_ip
    # TODO find out how wwe can take remote ip
    # self.current_login_ip = env['REMOTE_ADDR']
    self.current_login_at = Time.now
    self.number_of_logins = self.number_of_logins + 1
  end


  def save_login!
    save_login
    save :validate => false
  end
end
