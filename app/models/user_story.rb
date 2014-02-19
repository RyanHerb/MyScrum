class UserStory < Sequel::Model
  one_to_many :tests
  many_to_one :project
  
  	def validate
    	validates_presence :title, :message => 'Title must not be blank'
    	validates_unique :title

    	validates_presence :description, :message => 'Description must not be blank'
  	end
end
