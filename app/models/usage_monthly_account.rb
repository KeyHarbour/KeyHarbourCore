class UsageMonthlyAccount < ApplicationRecord
  belongs_to :account
  validates :month, presence: true, uniqueness: { scope: [ :account_id ] }
end
