class User < Sequel::Model
  include GeneralUser
  extend GeneralUser::ClassMethods
end
