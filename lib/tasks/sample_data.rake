namespace :db do
  desc "Fill database with sample data"
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
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
    
    50.times do
      User.all(:limit => 6).each do |user|
        user.tuckers.create(:title => Faker::Lorem.words(2).join(" "),
                            :description => Faker::Lorem.sentence(10),
                            :lat => rand * 180.0 - 90.0,
                            :lng => rand * 360.0 - 180.0)
      end
    end
  end
end