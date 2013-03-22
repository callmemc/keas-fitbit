# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


walking = HealthStatistic.create(name: 'walking', description: 'walking')
FitbitResource.create(health_statistic_id: walking.id, name: 'Walking') #capitalized

body_weight = HealthStatistic.create(name: 'body_weight', description: 'weight')
body_fat = HealthStatistic.create(name: 'body_fat', description: '% body fat')