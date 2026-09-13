class License::Instance < ApplicationRecord
  include Archivable
  include Uuidable
  
  belongs_to :application, class_name: 'License::Application'
  has_many :licensees, class_name: 'License::Licensee', dependent: :destroy
  has_one_attached :logo
  validates :name, presence: true
  validates :short_name, presence: true

  scope :active,          -> { joins(:application).where(application: { status: Organization.statuses[:active] }, status: Organization.statuses[:active]) }
  scope :not_archived,    -> { joins(:application).where.not(application: { status: Organization.statuses[:archived] }, status: Organization.statuses[:archived]) }
  scope :disabled,        -> { joins(:application).where(application: { status: Organization.statuses[:disabled] }, status: Organization.statuses[:disabled]) }
  scope :archived,        -> { joins(:application).where(application: { status: Organization.statuses[:archived] }, status: Organization.statuses[:archived]) }
  # validates :owner, presence: true

  def cost
    unit_cost || application.unit_cost || 0
  end

  def usage_rate
    return 1.0 * licensees.count / (seats || application&.seats) if (seats || application&.seats || 0) != 0
    nil
  end
end
