class Owner < Sequel::Model
  include GeneralUser
  extend GeneralUser::ClassMethods

  # ================
  # = Associations =
  # ================

  many_to_many :jobs
  many_to_many :projects, class: :Project , join_table: :users_projects, left_key: :user, right_key: :project, :select => [:projects.*, :users_projects__position]
  one_to_many :notifications

  # ==============
  # = Validation =
  # ==============

  def validate
    super
    validates_presence :username, :message => 'Username must not be blank'
    validates_unique :username
  end
end
