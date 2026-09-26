class License::Application < ApplicationRecord
  include MeiliSearch::Rails
  include Archivable
  include Uuidable
  belongs_to :account
  has_many :app_instances, class_name: 'License::Instance', dependent: :destroy
  has_many :licensees, through: :app_instances
  has_many :quotes, class_name: 'License::Quote', dependent: :destroy
  has_one_attached :logo
  validates :name, presence: true
  validates :short_name, presence: true
  validates :owner, presence: true
  validates :vendor, presence: true
  attr_accessor :renewal

  def seat_used
    app_instances.active.sum { |instance| instance.licensees.count }
  end

  def usage_rate
    return (1.0 * seat_used) / seats if (seats || 0) != 0
    0
  end

  def usage_rate_level
    # logger.debug "#{name} - #{usage_rate * 100}".red
    case usage_rate * 100
    when 0..69
      0
    when 70..89
      1
    when 90..100
      2
    else
      3
    end
  end

  def self.seat_used
    includes(:app_instances).sum { |app| app.app_instances.active.sum { |instance| instance.licensees.count } }
  end

  def renewal_level
    return 3 if renewal_date.nil?
    return 0 if renewal_date <= DateTime.now
    return 1 if renewal_date < DateTime.now.advance(days: alert_renewal_2)
    return 2 if renewal_date < DateTime.now.advance(days: alert_renewal_1)
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
    add_attribute :renewal_level do
      renewal_level
    end
    add_attribute :usage_rate_level do
      usage_rate_level
    end
    
    add_attribute :account_id do
      account&.id
    end
    searchable_attributes [ :name, :short_name, :owner, :vendor, :renewal_date, :tier, :account_id, :renewal_level, :usage_rate_level ]
    filterable_attributes [ :name, :short_name, :owner, :vendor, :renewal_date, :tier, :account_id, :renewal_level, :usage_rate_level ]
  end


  def self.events(start_date, end_date)
    self.where(status: 0, renewal_date: start_date..end_date).map do |application|
      {
        id: application.id,
        title: application.name,
        start: application.renewal_date.iso8601,
        end: application.renewal_date.iso8601,
        color: application.renewal_color,
        item: application
        # url: Rails.application.routes.url_helpers.member_license_application_path(application)
      }
    end
  end

  # def renewal_color
  #   return 'bg-red' if renewal_level == 0
  #   return 'bg-yellow' if  renewal_level == 1
  #   return 'bg-primary' if  renewal_level == 2
  #   'bg-green'
  # end

  def renewal_color
    return '#D63939' if renewal_level == 0
    return '#E08B42' if  renewal_level == 1
    return '#0B5351' if  renewal_level == 2
    '#5DEC89'
  end
end
