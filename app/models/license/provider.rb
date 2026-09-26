
class License::Provider < ApplicationRecord
  belongs_to :account
  has_many :license_quotes, class_name: 'License::Quote', foreign_key: 'license_provider_id'

  # Validations
  validates :name, presence: true
  validates :uuid, presence: true, uniqueness: { case_sensitive: false }
end
