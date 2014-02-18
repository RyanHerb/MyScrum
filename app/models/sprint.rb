class Sprint < Sequel::Model

	many_to_one :project
	many_to_many :user_stories
  
end
