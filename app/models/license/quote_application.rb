class License::QuoteApplication < ApplicationRecord
  belongs_to :application, class_name: 'License::Application', foreign_key: 'license_application_id'
  belongs_to :quote, class_name: 'License::Quote', foreign_key: 'license_quote_id'

  validates :amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
