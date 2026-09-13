class UsageDailyWorkspace < ApplicationRecord
  belongs_to :workspace
  enum :service_name, Cost.service_names
  validates :service_name, presence: true
  validates :day, presence: true, uniqueness: { scope: [ :workspace_id, :service_name ] }
end
