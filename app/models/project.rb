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

  def getTests
    arr = Array.new
    self.user_stories.each do |i|
      arr << i.tests
    end
    arr.flatten
  end

  
end
