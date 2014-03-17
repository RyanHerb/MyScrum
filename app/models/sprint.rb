class Sprint < Sequel::Model

  many_to_one :project
  many_to_many :user_stories

    def validate
      validates_presence :duration, :message => 'You must select a valid duration'
      unique_date
    end 

    def unique_date
      unless self.start_date.nil? or self.project_id.nil? or self.duration.nil?
        Project.find(:id => self.project_id).sprints_dataset.each do |s|
          unless s.pk == self.id
            if (self.start_date <= s.start_date + s.duration * 24 * 60 * 60 and self.start_date >= s.start_date) or (self.start_date + self.duration * 24 * 60 * 60 >= s.start_date and self.start_date + self.duration * 24 * 60 * 60  <= s.start_date + s.duration * 24 * 60 * 60)
              self.errors.add(:start_date, 'The date and duration you have chosen are overlapping with another sprint.')
              break
            end
          end
        end
      end
    end
end
