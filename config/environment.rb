# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
FitBit::Application.initialize!

ENV["REDISTOGO_URL"] ||= "redis://redistogo:00b05725a37066e1b63d591bd4ac1326@dory.redistogo.com:10613/"

require 'fitgem_extensions'
