Sequel.migration do
  up do
    # add table admins
    create_table(:admins) do
      primary_key :id, :auto_increment => true
      String :email
      String :first_name, :size => 32
      String :last_name, :size => 32
      String :hashed_password, :size => 80
      
      # Logging Log In
      String :last_login_ip, :size => 20
      DateTime :last_login_at
      String :current_login_ip, :size => 20
      DateTime :current_login_at
      Integer :number_of_logins, :default => 0
      
      DateTime :created_at
      DateTime :updated_at
    end
    self[:admins].insert(
      [:email, :first_name, :last_name, :hashed_password, :created_at, :updated_at], 
      ['rya.herb@gmail.com', 'Ryan', 'Herbert', Digest::SHA1.hexdigest('pass'), Time.now , Time.now]
    )
  end

  down do
    drop_table(:admins)
  end
end
