class ProcessedDate < ApplicationRecord
  validates :day, presence: true, uniqueness: true
end
