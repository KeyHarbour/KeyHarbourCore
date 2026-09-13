class EnvironmentsProject < ApplicationRecord
  belongs_to :project
  belongs_to :environment
end
