class UsageDailyProject < ApplicationRecord
  belongs_to :project
  enum :service_name, Cost.service_names
  validates :service_name, presence: true
  validates :day, presence: true, uniqueness: { scope: [ :project_id, :service_name ] }
end
