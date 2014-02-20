class Notification < Sequel::Model

  many_to_one :owner
  
end
