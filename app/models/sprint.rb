require 'date'
class Sprint < Sequel::Model


  many_to_one :project
  many_to_many :user_stories

    def validate
      validates_presence :duration, :message => 'You must select a valid duration'
    end 

    # ===========
    # = Subsets =
    # ===========

    # ====================
    # = Instance Methods =
    # ====================

    def expired
      start_date.to_date < Date.today - duration
    end
end
  