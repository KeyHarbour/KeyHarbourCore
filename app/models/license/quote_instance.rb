class License::QuoteInstance < ApplicationRecord
  belongs_to :instance, class_name: 'License::Instance', foreign_key: 'license_instance_id'
  belongs_to :quote, class_name: 'License::Quote', foreign_key: 'license_quote_id'

  validates :amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
