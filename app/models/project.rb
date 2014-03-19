class Project < Sequel::Model
  require 'uri'

	# ================
	# = Associations =
	# ================
  
  one_to_many :sprints
  one_to_many :user_stories

	many_to_many :users, class: :Owner , join_table: :users_projects, left_key: :project, right_key: :user, :select => [:owners.*, :users_projects__position]

  def validate
    validates_presence :title, :message => 'Title must not be blank'
    validates_unique :title
    validates_format URI.regexp, :repo, :allow_blank => true, :message => 'Repository URL is not valid'
  end

  # ====================
  # = Instance Methods =
  # ====================

  def has_rights(user)
    u = users_dataset.where(:user => user.pk).first
    unless u.nil?
      u.values[:position] == 'product owner' || u.values[:position] == 'scrum master'
    else
      false
    end
  end

  def developers
    users_dataset.where(:position => 'developer').all
  end

  def product_owners
    users_dataset.where(:position => 'product owner').all
  end

  def scrum_masters
    users_dataset.where(:position => 'product owner').all
  end
  
end
