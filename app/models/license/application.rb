class License::Application < ApplicationRecord
  include MeiliSearch::Rails
  include Archivable
  include Uuidable
  belongs_to :organization
  has_many :app_instances, class_name: 'License::Instance', dependent: :destroy
  has_many :licensees, through: :app_instances
  has_one_attached :logo
  validates :name, presence: true
  validates :short_name, presence: true
  validates :owner, presence: true
  validates :vendor, presence: true

  def seat_used
    app_instances.active.sum { |instance| instance.licensees.count }
  end

  def usage_rate
    return (1.0 * seat_used) / seats if (seats || 0) != 0
    0
  end

  def self.seat_used
    includes(:app_instances).sum { |app| app.app_instances.active.sum { |instance| instance.licensees.count } }
  end

  def renewal_level
    return 0 if renewal_date < DateTime.now
    return 1 if renewal_date < DateTime.now.advance(days: alert_renewal_1)
    return 2 if renewal_date < DateTime.now.advance(days: alert_renewal_2)
    3
  end

  def seat_level
    return 0 if usage_rate > 1
    return 1 if usage_rate > alert_seats_2
    return 2 if usage_rate > alert_seats_1
    3
  end

  meilisearch do
    add_attribute :id
    add_attribute :name
    add_attribute :short_name
    add_attribute :owner
    add_attribute :vendor
    add_attribute :renewal_date
    add_attribute :tier
    add_attribute :organization_id do
      organization&.id
    end
    searchable_attributes [ :name, :short_name, :owner, :vendor, :renewal_date, :tier, :organization_id ]
    filterable_attributes [ :name, :short_name, :owner, :vendor, :renewal_date, :tier, :organization_id ]
  end
end
