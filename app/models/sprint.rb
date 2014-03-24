require 'date'
class Sprint < Sequel::Model


  many_to_one :project
  many_to_many :user_stories

    def validate
      validates_presence :duration, :message => 'You must select a valid duration'
      unique_date
    end 

    def validates_future_date
      if new?
        if start_date.to_date.past?
          errors.add(:start_date, 'You may not start a sprint in the past')
        end
      end
    end

    def unique_date
      unless self.start_date.nil? or self.project_id.nil? or self.duration.nil?
        self_date = self.start_date.to_date
        Project.find(:id => self.project_id).sprints_dataset.each do |s|
          s_date = s.start_date.to_date
          unless s.pk == self.id
            if (self_date <= s_date + s.duration and self_date >= s_date) or (self_date + self.duration >= s_date and self_date + self.duration  <= s_date + s.duration)
              self.errors.add(:start_date, 'The date and duration you have chosen are overlapping with another sprint.')
              break
            end
          end
        end
      end
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
