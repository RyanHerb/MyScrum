class UserStory < Sequel::Model

  one_to_many :jobs
  one_to_many :tests
  many_to_one :project
  many_to_many :sprints


    def validate
      validates_presence :title, :message => 'Title must not be blank'
      validates_unique :title
      validates_presence :description, :message => 'Description must not be blank'
      validates_presence :priority, :message => 'Priority must not be blank'
      validates_presence :difficulty, :message => 'Difficulty must not be blank'
      validates_includes 1 .. 99999999, :difficulty, :message => 'Difficulty must be > 0'
      validates_includes 1 .. 99999999, :priority, :message => 'Priority must be > 0'
    end
end
