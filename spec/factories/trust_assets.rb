FactoryBot.define do
  factory :trust_asset do
    association :workspace
    association :environment
    sequence(:name) { |n| "asset-name-#{n}.com" }
    expires_at { Time.current.advance(days: 30) }
    issuer { "MyString" }
    format { 1 }
    consumer { "MyString" }
    description { "MyText" }
    reminder_days { 1 }
  end
end
