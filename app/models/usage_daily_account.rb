class UsageDailyAccount < ApplicationRecord
  belongs_to :account
  enum :service_name, Cost.service_names
  validates :service_name, presence: true
  validates :day, presence: true, uniqueness: { scope: [ :account_id, :service_name ] }
end
