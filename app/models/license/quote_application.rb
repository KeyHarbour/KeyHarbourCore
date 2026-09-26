class License::QuoteApplication < ApplicationRecord
  belongs_to :application, class_name: 'License::Application', foreign_key: 'application_id'
  belongs_to :quote, class_name: 'License::Quote', foreign_key: 'quote_id'
  has_many :quote_instances , class_name: 'License::QuoteInstance', foreign_key: 'quote_application_id'

  validates :amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  def total
    quote_instances.where(unused: false).sum { |quote_instance| quote_instance.total.to_i } + (amount || 0)
  end
  
  def unit_cost
    return total if seats.nil? || seats.zero?
    total * 1.0 / seats
  end  
end
