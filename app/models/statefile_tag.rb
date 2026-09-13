class StatefileTag < ApplicationRecord
  belongs_to :statefile
  validates :tag, uniqueness: { scope: [ :statefile_id ] }, format: { with: /\A[a-z0-9]*\z/, message: :alphanumeric_only }
end
