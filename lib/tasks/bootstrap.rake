namespace :db do 
  desc "create default admin user" 
  task :create_admin => :environment do 
    admin = User.create( 
      :name => "admin", 
      :email => "harrism@gmail.com",
      :password => "admin", 
      :password_confirmation => "admin",
    ) 
    admin.toggle!(:admin)
    admin.save
  end 
end