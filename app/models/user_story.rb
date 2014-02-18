class UserStory < Sequel::Model
  
  	def validate
    	validates_presence :title, :message => 'Title must not be blank'
    	validates_unique :title

    	validates_presence :description, :message => 'Description must not be blank'
  	end
end
