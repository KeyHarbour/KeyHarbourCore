class License::Quote < ApplicationRecord
  belongs_to :application, class_name: 'License::Application', foreign_key: 'license_application_id'
  belongs_to :provider, class_name: 'License::Provider', foreign_key: 'license_provider_id'
  has_many :license_quote_instances, class_name: 'License::QuoteInstance', foreign_key: 'license_quote_id'
  has_many :license_quote_add_ons, class_name: 'License::QuoteAddOn', foreign_key: 'license_quote_id'
  has_many :license_quote_applications, class_name: 'License::QuoteApplication', foreign_key: 'license_quote_id'
  validates :uuid, presence: true, uniqueness: { case_sensitive: false }

  after_commit :update_unit_cost, if: -> { set_to_approved? }

  private

  def set_to_approved?
    change = saved_change_to_approved_at
    
    change.present? && change[0].nil? && change[1].present?
  end

  def update_unit_cost
    logger.debug "Updating unit cost for license quote #{id} to #{license_provider.unit_cost}"
  end
end