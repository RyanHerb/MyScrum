class Project < Sequel::Model

	# ================
	# = Associations =
	# ================

	many_to_many :users, class: :Owner , join_table: :user_project, left_key: :project, right_key: :user

  def validate
    validates_presence :title, :message => 'Title must not be blank'
    validates_unique :title
  end
  
end
