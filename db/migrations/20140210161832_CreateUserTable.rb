Sequel.migration do
  up do
    create_table(:users) do
      primary_key :id, :auto_increment => true
      String :email, :size => 64
      String :username, :size => 64
      String :first_name, :size => 16
      String :last_name, :size => 16
      TrueClass :admin, :default => false

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
    self[:users].insert(
      [:email, :first_name, :last_name, :hashed_password, :created_at, :updated_at, :admin], 
      ['email@mail.com', 'First', 'user', Digest::SHA1.hexdigest('pass'), Time.now , Time.now, 1]
    )
  end

  down do
    drop_table(:users)
  end
end
