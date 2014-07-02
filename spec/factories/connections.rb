FactoryGirl.define do
  sequence :uid do |n|
    n.to_s
  end
  factory :connection, class: 'Connection' do
    provider :developer
    uid
    name { Faker::Name.name }
    image 'https://si0.twimg.com/profile_images/2900491556/9d2bf873770958647f18b8e61af31f1a.png'
    access_token 'abcdefg'
    secret_token 'hijklmn'
    nickname { Faker::Name.last_name.downcase }
  end
end
