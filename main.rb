ROOT_DIR = File.expand_path File.dirname(__FILE__)

puts "Launching MyScrum in \e[01;32m#{ENV['RACK_ENV']}\033[0m mode"
require 'sequel/adapters/mysql2';

# =================
# = Configuration =
# =================

configure do
  
  set :root, File.dirname(__FILE__)
                               
  Sequel.extension :blank
  
  # Loading the config file depending on the environment
  CONFIG = YAML.load_file("#{ROOT_DIR}/config/global.yaml").merge(YAML.load_file("#{ROOT_DIR}/config/#{ ENV['RACK_ENV'] }.yaml"))
  
  # Connect to the database
  DB_OPTIONS = YAML.load_file("config/database.yaml")[ENV['RACK_ENV']] rescue {}
  
  if DB_OPTIONS.length > 0 && DB_OPTIONS['password'] != 'MyScrumMySQLPass' 
    
    DB = Sequel.connect(DB_OPTIONS) 
    
    DB << 'set names utf8'
    
  end
  
  session_options = { 
    :key => 'rack.session', 
    :path => '/',
    :secret => 'MyScrum-session-secret'
  }
  session_options[:domain] = CONFIG['cookie_domain'] if CONFIG['cookie_domain']
  
  use Rack::Session::Cookie, session_options

  # ===================
  # = Mailer settings =
  # ===================
  set :mailer_test_domains, %w(gmail.com)
  set :mailer_from_name, "MyScrum"
  set :mailer_from_email, 'rya.herb@gmail.com'
  
end

configure :production do
  set :sass, {:style => :compressed }
  set :raise_errors, true
  Dir.mkdir('log') unless File.exist?('log')

  $logger = Logger.new('log/production.log','weekly')
  $logger.level = Logger::WARN

  # Spit stdout and stderr to a file during production
  # in case something goes wrong
  $stdout.reopen("log/output.log", "a")
  $stdout.sync = true
  # $stderr.reopen($stdout)

  DB.loggers << $logger if $logger
  DB.log_warn_duration = 0.2
end

configure :development do
  set :show_exceptions, true
  set :raise_errors, false
  set :sass, {:style => :compact }
  Dir.mkdir('log') unless File.exist?('log')

  $logger = Logger.new('log/development.log','weekly')
  $logger.level = Logger::INFO

  # Spit stdout and stderr to a file during production
  # in case something goes wrong
  $stdout.reopen("log/output.log", "a")
  $stdout.sync = true
  $stderr.reopen($stdout)

  DB.loggers << $logger if $logger
  DB.log_warn_duration = 0.2
  
end

configure :local do
  Dir.mkdir('log') unless File.exist?('log')
  set :sass, {:style => :expanded }
  set :raise_errors, false
  enable :show_exceptions, :reload_templates  
  DB.loggers << Logger.new(STDOUT)
end
# 
# configure do
#   # Turning DB logging on
#   DB.loggers << Logger.new( DB_OPTIONS['logfile'] ) if DB_OPTIONS['logfile'] 
# end

# ===============
# = FORKING FUN =
# ===============

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    if forked
      # We're in smart spawning mode.
      puts "FORKING Hell, reconnecting to the database"
      # DB.loggers.first.info("Reconnecting Passenger worker to MySQL after fork...")
      DB.disconnect
      # DB.connect(db_options)
    else
      # We're in conservative spawning mode. We don't need to do anything.
    end
  end
end

# ==================================================
# = A railslike layout so we don't scare people ;) =
# ==================================================


# load initializers
Dir[ROOT_DIR + '/config/initializers/*.rb'].each {|file| require file }

# load models
Dir[ROOT_DIR + '/app/models/*.rb'].each {|file| require file } if defined?(DB)

# load helpers
Dir[ROOT_DIR + '/app/helpers/*.rb'].each {|file| require file }

# load "controllers"
Dir[ROOT_DIR + '/app/controllers/*.rb'].each {|file| require file }
