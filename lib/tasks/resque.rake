require 'resque/tasks'

#task "resque:setup" => :environment

task "resque:setup" => :environment do
  ENV['QUEUE'] = '*'
  Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection } #new
end

desc "Alias for resque:work (To run workers on Heroku)"
task "jobs:work" => "resque:work"