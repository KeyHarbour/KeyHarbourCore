class License::QuoteAddOn < ApplicationRecord
  belongs_to :add_on, class_name: 'License::AddOn', foreign_key: 'add_on_id'
  belongs_to :quote_instance, class_name: 'License::QuoteInstance', foreign_key: 'quote_instance_id'

  validates :amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
