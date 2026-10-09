class License::QuoteInstance < ApplicationRecord
  belongs_to :instance, class_name: 'License::Instance', foreign_key: 'instance_id'
  belongs_to :quote_application, class_name: 'License::QuoteApplication', foreign_key: 'quote_application_id'

  has_many :quote_add_ons, class_name: 'License::QuoteAddOn', foreign_key: 'quote_instance_id'

  validates :amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  def total_with_application
    return 0 if unused == true

    if quote_application.amount.nil? || quote_application.amount.zero?
      app_cost = 0
    else
      app_cost = quote_application.amount / quote_application.seats * (seats || 1)
    end
    quote_add_ons.where(unused: false).sum { |addon| addon.amount.to_i } + (amount || 0) + app_cost
  end

  def total
    return 0 if unused == true
    
    quote_add_ons.where(unused: false).sum { |addon| addon.amount.to_i } + (amount || 0)
  end

  def unit_cost
    return total if seats.nil? || seats.zero?
    total * 1.0 / seats
  end

  def unit_cost_with_application
    return total_with_application if seats.nil? || seats.zero?
    total_with_application * 1.0 / seats
  end
end
