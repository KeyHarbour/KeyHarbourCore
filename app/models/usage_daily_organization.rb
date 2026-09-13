class UsageDailyOrganization < ApplicationRecord
  belongs_to :organization
  enum :service_name, Cost.service_names
  validates :service_name, presence: true
  validates :day, presence: true, uniqueness: { scope: [ :organization_id, :service_name ] }
end
