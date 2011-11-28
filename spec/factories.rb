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
  tucker.title "Fig Tree"
  tucker.description "Growing in the gardens point Botanical Gardens in Brisbane."
  tucker.address "City Botanical Gardens, Brisbane, Queensland, Australia"
  tucker.latitude 40.0
  tucker.longitude 0.0
  tucker.association :user
end
