class License::AddOn < ApplicationRecord
  belongs_to :instance, class_name: 'License::Instance', foreign_key: 'instance_id'
  has_many :quote_add_ons, class_name: 'License::QuoteAddOn', foreign_key: 'add_on_id'

  validates :name, presence: true
  validates :uuid, presence: true, uniqueness: true
  validates :unit_cost, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
