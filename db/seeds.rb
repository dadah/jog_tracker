# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
unless Rails.env.test?
  admin = User.find_by email: 'admin@jogtracker.com'

  unless admin.present?
    admin = User.create name: 'Administrator', email: 'admin@jogtracker.com', password: 'admin@jog', role: 'admin'
  end
end
