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
1000.times do
  u = User.all.sample.downlines.create(random_creds(User.last.id))
  display_user_and_uplines(u)
end

def random_score_for_game_id(user, bell_curve=5, max_score=100)
  game = Game.first
  total = 0
  bell_curve.times { total += rand(max_score) }
  score = (total/bell_curve).round
  puts "#{user.first_name}#{user.id} : #{score}"
  user.new_score_for_game_code("#{user.first_name}#{user.id}", game.code, score)
end

def random_purchase_for_user(user)
  return nil unless user
  game = Game.first
  purchase_amount = ([0.99, 1.99, 3.99, 5.99].sample * 100).round
  puts "#{user.username_for_game(game)} : #{purchase_amount}"
  user.new_purchase_for_game_code(game.code, purchase_amount)
end

1000.times do
  random_score_for_game_id(User.all.sample)
end
500.times do
  random_purchase_for_user(User.all.sample)
end

def random_user
  inc_id = User.last ? User.last.id + 1 : 1
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
  PurchaseTracker.all.each do |tracker|
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

check_all_trackers
