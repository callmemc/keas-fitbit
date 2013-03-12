ENV["REDISTOGO_URL"] ||= "redis://redistogo:00b05725a37066e1b63d591bd4ac1326@dory.redistogo.com:10613/"

uri = URI.parse(ENV["REDISTOGO_URL"])

Rails.logger('uri')
Rails.logger(uri)

Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

Dir["#{Rails.root}/app/jobs/*.rb"].each { |file| require file }
