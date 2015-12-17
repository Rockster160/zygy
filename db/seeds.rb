# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

puts Game.create(name: 'Pirate Pike') # 169181205-64169115
puts Game.create(name: 'Tower Defense') # 201523518-64456514195
puts Game.create(name: 'Random Game') # 1811441513-6471135

def random_creds(id)
  first_name = ::Faker::Name.first_name
  last_name = ::Faker::Name.last_name
  {first_name: first_name, last_name: last_name, email: "#{first_name.downcase}#{last_name.downcase}#{id}@email.com", password: 'password'}
end

def display_user_and_uplines(user)
  all_uplines = user.uplines_by(100)
  puts "#{all_uplines.map(&:id).join(' ')} : #{user.id}"
end

5.times do
  u = User.create(random_creds(rand(1000)))
  display_user_and_uplines(u)
end
# 1000.times do
#   u = User.all.sample.downlines.create(random_creds(User.last.id))
#   display_user_and_uplines(u)
# end

def generate_scores_for_downlines(user)
  return nil unless user
  game = Game.first
  score = rand(1000)
  user.new_score_for_game_code("#{user.first_name.downcase}#{user.id}", game.code, score)
  puts "#{user.username_for_game(game)} : #{score}"
  generate_scores_for_downlines(user.downlines.sample) if user.downlines
end

# 3000.times do
#   generate_scores_for_downlines(User.all.sample)
# end

def random_score_for_game_id(game_id, bell_curve=5, max_score=100)
  game = Game.find(game_id)
  total = 0
  bell_curve.times { total += rand(max_score) }
  score = (total/bell_curve).round
  user = User.all.sample
  puts "#{user.first_name}#{user.id} : #{score}"
  user.new_score_for_game_code("#{user.first_name}#{user.id}", game.code, score)
end

def random_user
  inc_id = User.last.id + 1
  first_name = ::Faker::Name.first_name
  last_name = ::Faker::Name.last_name
  User.create(
    first_name: first_name,
    last_name: last_name,
    email: "#{first_name.downcase}#{last_name.downcase}#{inc_id}@email.com",
    password: 'password'
  )
end

def check_all_trackers
  all_passed = true
  count = {true: 0, false: 0}
  UserScoreTracker.all.each do |tracker|
    passed = tracker.refresh
    count[passed.to_s.to_sym] += 1
    all_passed = false unless passed
  end
  if all_passed
    puts "", "All Passed!!".colorize(:green)
  else
    puts "", "Failure!!".colorize(:red)
  end
  print count[:true].to_s.colorize(:green)
  print " / "
  puts count[:false].to_s.colorize(:red)
  all_passed
end
