class Owner < Sequel::Model
  include GeneralUser
  extend GeneralUser::ClassMethods

  # ================
  # = Associations =
  # ================

  many_to_many :jobs
  many_to_many :projects, class: :Project , join_table: :users_projects, left_key: :user, right_key: :project, :select => [:projects.*, :users_projects__position]
  one_to_many :notifications

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
