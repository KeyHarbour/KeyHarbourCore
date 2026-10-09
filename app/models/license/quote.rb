class License::Quote < ApplicationRecord
  STATUSES = {
    intial: :initial,
    ready: :ready,
    rejected: :rejected,
    approved: :approved
  }
  include MeiliSearch::Rails
  belongs_to :application, class_name: 'License::Application', foreign_key: 'application_id'
  belongs_to :provider, class_name: 'License::Provider', foreign_key: 'provider_id'
  has_many :quote_applications, class_name: 'License::QuoteApplication', foreign_key: 'quote_id'

  has_many :quote_instances, class_name: 'License::QuoteInstance', through: :quote_applications, source: :quote_instances
  has_many :quote_add_ons, class_name: 'License::QuoteAddOn', through: :quote_instances, source: :quote_add_ons
  validates :uuid, presence: true, uniqueness: { case_sensitive: false }
  enum :status, License::Quote::STATUSES

  after_commit :update_unit_cost, if: -> { set_to_approved? }

  def total
    result = 0
    quote_applications.each do |quote_application|
      result += quote_application.total
    end
    result
  end

  private

  def set_to_approved?
    change = saved_change_to_approved_at
    
    change.present? && change[0].nil? && change[1].present?
  end

  def update_unit_cost
    logger.debug "Updating unit cost for license quote #{id} to #{license_provider.unit_cost}"
  end

  meilisearch do
    add_attribute :id
    add_attribute :uuid
    add_attribute :available_on
    add_attribute :available_until
    add_attribute :approved_at
    add_attribute :status
    add_attribute :application_id do
      application&.id
    end
    add_attribute :provider_id do
      provider&.id
    end
    searchable_attributes [ :uuid, :available_on, :available_until, :approved_at, :status, :application_id, :provider_id ]
    filterable_attributes [ :uuid, :available_on, :available_until, :approved_at, :status, :application_id, :provider_id ]
  end  
end