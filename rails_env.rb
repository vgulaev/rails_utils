require 'pathname'
require 'socket'
require_relative 'secrets'

def init_rails(options = {})
  current_path = Dir.pwd
  if UT::DEV_HOST == Socket.gethostname
    app_path = Pathname.new( UT::DEV_PATH )
  else
    app_path = Pathname.new( UT::SRV_PATH )
  end
  Dir.chdir app_path

  require app_path.to_s + '/config/environment'
  
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  ActiveRecord::Base.logger = nil if options.key?(:sql_logger_off)

  STDOUT.sync = true

  Dir.chdir current_path
end

def dev?
  UT::DEV_HOST == Socket.gethostname
end

def only_dev
  unless dev?
    puts('Very dangerous script, can use only in dev env')
    exit
  end 
end