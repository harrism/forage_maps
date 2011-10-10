# By using the symbol ':user', we get Factory Girl to simulate the User model.
Factory.define :user do |user|
  user.name                   "John Doe"
  user.email                  "jdoe@example.com"
  user.password               "foobar"
  user.password_confirmation  "foobar"
end

Factory.sequence :email do |n|
  "person-#{n}@example.com"
end

Factory.define :tucker do |tucker|
  tucker.title "A Tucker"
  tucker.description "Growing somewhere."
  tucker.lat 40.0
  tucker.lng 0.0
  tucker.association :user
end
