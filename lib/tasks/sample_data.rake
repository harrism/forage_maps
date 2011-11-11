namespace :db do
  desc "Fill database with sample data"
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    make_users
    make_relationships
    make_tuckers
  end
end

def make_users
  admin = User.create!(:name => "Example User",
                       :email => "example@foragemaps.com",
                       :password => "foobar",
                       :password_confirmation => "foobar")
  admin.toggle!(:admin)
  99.times do |n|
    name = Faker::Name.name
    email = "example-#{n+1}@foragemaps.com"
    password = "password"
    User.create(:name => name,
                :email => email,
                :password => password,
                :password_confirmation => password)
  end
end

def make_relationships
  users = User.all
  user = users.first
  following = users[1..50]
  followers = users[3..40]
  following.each { |followed| user.follow!(followed) }
  followers.each { |follower| follower.follow!(user) }
end
  
def make_tuckers
  User.all(:limit => 6).each do |user|
    50.times do
      title = Faker::Lorem.words(2).join(" ")
      description = Faker::Lorem.sentence(10)
      user.tuckers.create(:title => title,
                          :description => description,
                          :lat => rand * 180.0 - 90.0,
                          :lng => rand * 360.0 - 180.0)
    end
  end
end