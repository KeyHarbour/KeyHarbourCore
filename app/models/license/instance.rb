class License::Instance < ApplicationRecord
  include MeiliSearch::Rails
  include Archivable
  include Uuidable
  
  belongs_to :application, class_name: 'License::Application'
  has_many :licensees, class_name: 'License::Licensee', dependent: :destroy
  has_many :add_ons, class_name: 'License::AddOn', dependent: :destroy
  has_many :quote_instances, class_name: 'License::QuoteInstance', foreign_key: 'instance_id'
  has_one_attached :logo
  validates :name, presence: true
  validates :short_name, presence: true

  scope :active,          -> { joins(:application).where(application: { status: Organization.statuses[:active] }, status: Organization.statuses[:active]) }
  scope :not_archived,    -> { joins(:application).where.not(application: { status: Organization.statuses[:archived] }, status: Organization.statuses[:archived]) }
  scope :disabled,        -> { joins(:application).where(application: { status: Organization.statuses[:disabled] }, status: Organization.statuses[:disabled]) }
  scope :archived,        -> { joins(:application).where(application: { status: Organization.statuses[:archived] }, status: Organization.statuses[:archived]) }
  # validates :owner, presence: true

  def cost
    (unit_cost || application.unit_cost || 0) + add_ons.where(active: true).sum(:unit_cost)
  end

  def cost_with_add_ons
    unit_cost + add_ons.sum(&:unit_cost)
  end

  def cost_with_active_add_ons
    unit_cost + add_ons.where(active: true).sum(&:unit_cost)
  end

  def seat_used
    licensees.count
  end

  def usage_rate
    return 1.0 * licensees.count / (seats || application&.seats) if (seats || application&.seats || 0) != 0
    nil
  end

  meilisearch do
    add_attribute :id
    add_attribute :name
    add_attribute :short_name
    add_attribute :owner
    add_attribute :renewal_date
    add_attribute :licencess_allowed
    add_attribute :seats
    add_attribute :status
    add_attribute :account_id do
      application&.account&.id
    end
    add_attribute :application_id do
      application&.id
    end
    searchable_attributes [ :name, :short_name, :owner, :renewal_date, :licencess_allowed, :seats, :status, :account_id, :application_id ]
    filterable_attributes [ :name, :short_name, :owner, :renewal_date, :licencess_allowed, :seats, :status, :account_id, :application_id ]
  end
end
