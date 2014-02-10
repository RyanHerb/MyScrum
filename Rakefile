ENV['RACK_ENV']||='local'

require 'date'
require 'yaml'

ROOT_DIR = File.expand_path File.dirname(__FILE__)


task :app_environment => :database_settings do
  require 'sequel'
  
  # Loading the config file depending on the environment
  CONFIG = YAML.load_file("#{ROOT_DIR}/config/global.yaml").merge((YAML.load_file("#{ROOT_DIR}/config/#{ ENV['RACK_ENV'] }.yaml") rescue {}))
  
  DB = Sequel.connect(DB_OPTIONS)
  # load initializers
  Dir[ROOT_DIR + '/config/initializers/*.rb'].each {|file| require file }

  # load models
  Dir[ROOT_DIR + '/app/models/*.rb'].each {|file| require file } if defined?(DB)
end

"desc load database env"
task :database_settings do
  DB_OPTIONS = YAML.load_file("#{ROOT_DIR}/config/database.yaml")[ENV['RACK_ENV']]
end
namespace :app do 
  desc "get current version"
  task :version => :app_environment do
    say CONFIG['app_version']
  end
end
namespace :gen do
  
  desc "add sequel model"
  task :model => :app_environment do
    if ENV['name'].blank?
      error "Specify a name. rake gen:model name=ModelName"
    else
      ts = Time.now.strftime('%Y%m%d%H%M%S')
      model = ENV['name'].camelize
      table = model.underscore.pluralize
      migration = "Create#{model}"
      file = "#{ROOT_DIR}/db/migrations/#{ts}_#{migration}.rb"
      say "Create #{file}"
      File.open(file, 'w') do |f|
        f.write("Sequel.migration do\n")
        f.write("  up do\n")
        f.write("    # add table #{table}\n")
        f.write("    create_table(:#{table}) do\n")
        f.write("      primary_key :id, :auto_increment => true\n")
        f.write("      \n")
        f.write("      DateTime :created_at\n")
        f.write("      DateTime :updated_at\n")
        f.write("    end\n")
        f.write("  end\n")
        f.write("\n")
        f.write("  down do\n")
        f.write("    drop_table(:#{table})\n")
        f.write("  end\n")
        f.write("end\n")
      end
      `open "txmt://open?url=file://#{file}&line=6&column=7"`
      
      file = "#{ROOT_DIR}/app/models/#{model.underscore.downcase}.rb"
      say "Create #{file}"
      File.open(file, 'w') do |f|
        f.write("class #{model} < Sequel::Model\n")
        f.write("  \n")
        f.write("end\n")
      end
      `sleep 1 && open "txmt://open?url=file://#{file}&line=2&column=3"`      
    end    
  end

  desc "generate a new migration"
  task :migration => :app_environment do
    if ENV['name'].blank?
      error "Specify a name. rake db:update name=MyMigrationName"
    else
      ts = Time.now.strftime('%Y%m%d%H%M%S')
      migration = ENV['name'].camelize
      file = "#{ROOT_DIR}/db/migrations/#{ts}_#{migration}.rb"
      say "Create #{file}"
      File.open(file, 'w') do |f|
        f.write("Sequel.migration do\n")
        f.write("  up do\n")
        f.write("    \n");
        f.write("  end\n")
        f.write("\n")
        f.write("  down do\n")
        f.write("  end\n")
        f.write("end\n")
      end

      `open "txmt://open?url=file://#{file}&line=3&column=5"`
    end
  end
  
  desc "create a new controller file"
  task :controller => :app_environment do
    if ENV['name'].blank?
      error "Specify a name. rake gen:controller name=MyController [ url=startURL ]"
    else
      controller = ENV['name'].camelize
      parent = ENV['parent'].camelize rescue nil
      if parent
        file = "#{ROOT_DIR}/app/controllers/#{parent.downcase}/#{controller.downcase}.rb"
        dir = "#{ROOT_DIR}/app/controllers/#{parent.downcase}/"
        FileUtils.mkdir_p(dir) unless File.directory?(dir)
        if File.exists?(file)
          error "Controller file already exists!"
        else
          say "Create #{file}"
          File.open(file, 'w') do |f|
            f.write("module #{CONFIG['app_name']}\n")
            f.write("  class #{parent.camelize}App\n")
            f.write("    \n")
            f.write("    get '/#{controller.downcase}/' do\n")
            f.write("      haml :\"#{controller.downcase}/index\"\n")
            f.write("    end\n")
            f.write("    \n")
            f.write("  end\n")
            f.write("end\n")
          end
          `open "txmt://open?url=file://#{file}&line=5&column=5"`
        end
      else
        file = "#{ROOT_DIR}/app/controllers/#{controller.downcase}.rb"
        if File.exists?(file)
          error "Controller file already exists!"
        else
          say "Create #{file}"
          File.open(file, 'w') do |f|
            f.write("module #{CONFIG['app_name']}\n")
            f.write("  class #{controller}App < Sinatra::Application\n")
            f.write("    \n")
            f.write("    set :views, ROOT_DIR + '/app/views/#{controller.downcase}'\n")
            f.write("    \n")
            f.write("    get '/' do\n")
            f.write("      haml :index\n")
            f.write("    end\n")
            f.write("    \n")
            f.write("  end\n")
            f.write("end\n")
          end
        
          if url= ENV['url']
            File.open('config.ru', 'a') do |f|
              f.write("\n")
              f.write("map '#{url}' do\n")
              f.write("  run #{CONFIG['app_name']}::#{controller}App\n")
              f.write("end\n")
              f.write("\n")
            end
          end
        
          `open "txmt://open?url=file://#{file}&line=5&column=5"`
        end
      end

    end
  end
  
end

namespace :db do

  desc "drop database"
  task :drop => :database_settings do
        
    sql = "drop database #{DB_OPTIONS['database']}"
    say sql
    `echo "#{sql}" | mysql`
  end

  desc "create database based on database.yml (assumes your user has root privileges for mysql and ~/.my.cnf is setup)"
  task :create => :database_settings do
        
    sql = "create database if not exists #{DB_OPTIONS['database']}; grant all privileges on #{DB_OPTIONS['database']}.* to #{DB_OPTIONS['username']}@localhost identified by '#{DB_OPTIONS['password']}'; flush privileges"
    say sql
    `echo "#{sql}" | mysql`
  end

  desc "run database migrations"
  task :migrate => :database_settings do
    if defined?(DB_OPTIONS)
      puts `sequel -E -m db/migrations mysql2://#{DB_OPTIONS['username']}:#{DB_OPTIONS['password']}@#{DB_OPTIONS['host']}/#{DB_OPTIONS['database']}`
    else
      error "You need to setup config/database.yaml"
    end
  end
  
  desc "rollback database migrations"
  task :rollback => :database_settings do
    files = Dir["db/migrations/*.rb"]
    if defined?(DB_OPTIONS)
      if last = files[-2] then
        ts = last.gsub(/db\/migrations\//, '').gsub(/_.*/,'')
        puts `sequel -E -m db/migrations -M #{ts} mysql2://#{DB_OPTIONS['username']}:#{DB_OPTIONS['password']}@#{DB_OPTIONS['host']}/#{DB_OPTIONS['database']}`
      else
        puts `sequel -E -m db/migrations -M 0 mysql2://#{DB_OPTIONS['username']}:#{DB_OPTIONS['password']}@#{DB_OPTIONS['host']}/#{DB_OPTIONS['database']}`
      end
    else
      error "You need to setup config/database.yaml"
    end
  end
  
  namespace :schema do
    desc "dump database schema into db/schema.rb"
    task :dump => :database_settings do
      if defined?(DB_OPTIONS)
        say "Dumping db schema into db/schema.rb"
        `sequel -d mysql2://#{DB_OPTIONS['username']}:#{DB_OPTIONS['password']}@#{DB_OPTIONS['host']}/#{DB_OPTIONS['database']} > db/schema.rb`
      end
    end
    
    desc "load data base schema from db/schema.rb"
    task :load => :database_settings do
      say "Loading db schema frmo db/schema.rb"
      error " [ not implemented ]"
    end
    
  end

end

def error msg
  puts "#{`tput setaf 1`}#{msg}#{`tput sgr0`}"
end

def say msg
  puts "#{`tput setaf 2`}#{msg}#{`tput sgr0`}"
end
