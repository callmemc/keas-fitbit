class ResourceCollection < ActiveRecord::Base
  attr_accessible :resource_name, :collected, :resource_name, :date
  serialize :collected, Hash
end
