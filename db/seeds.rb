# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Game.create(name: 'Pirate Pike')

def random_creds
  {email: "#{::Faker::Name.first_name.downcase}#{::Faker::Name.last_name.downcase}@email.com", password: 'password'}
end

def display_user_and_uplines(user)
  all_uplines = user.uplines_by(100)
  puts "#{all_uplines.map(&:id).join(' ')} : #{user.id}"
end

3.times do
  u = User.create(random_creds)
  display_user_and_uplines(u)
end
150.times do
  u = User.all.sample.downlines.create(random_creds)
  display_user_and_uplines(u)
end

def scores_for_downlines(user)
  return nil unless user
  user.new_score_for_game('169181205-169115', rand(10000))
  scores_for_downlines(user.downlines.sample) if user.downlines
end

100.times do
  scores_for_downlines(User.topline.sample)
end
