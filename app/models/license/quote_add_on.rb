class License::QuoteAddOn < ApplicationRecord
  belongs_to :add_on, class_name: 'License::AddOn', foreign_key: 'license_add_on_id'
  belongs_to :quote, class_name: 'License::Quote', foreign_key: 'license_quote_id'

  validates :amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
