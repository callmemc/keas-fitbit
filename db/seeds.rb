# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


Notification.create!(:collectionType => "user", :date => '2010-03-01', :ownerId => "24N6YJ",
:ownerType => "user", :subscriptionId => "24N6YJ")