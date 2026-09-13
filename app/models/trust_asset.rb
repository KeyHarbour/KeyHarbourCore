class TrustAsset < ApplicationRecord
  VALID_FORMAT_REGEX = /\A[A-Za-z0-9\.\-\_]+\z/
  include MeiliSearch::Rails
  belongs_to :workspace
  belongs_to :environment
  validates :name, presence: true, 
                  uniqueness: { scope: [ :workspace_id, :environment_id ] },
                  format: { 
                    with: VALID_FORMAT_REGEX,
                    message: "only allows numbers, dots, dashes, and underscores" 
                  }
  validates :format, presence: true
  validates :issuer, presence: true
  validates :consumer, presence: true
  validates :expires_at, presence: true
  validate :expiration_date_cannot_be_in_the_past
  scope :active, -> { where("expires_at >= ? OR expires_at IS NULL", Time.current) }
  scope :for_environment, ->(env) { where(environment: env).includes(:environment) }
  after_save :index_to_meilisearch

  enum :format, {
    tls_certificate: 0,
    token: 1
  }

  private

  def expiration_date_cannot_be_in_the_past
    if expires_at.present? && expires_at < Time.current
      errors.add(:expires_at, "doit être une date future")
    end
  end

  def self.as_json_api(relation)
    relation.map do |trust_asset|
      {
        name: trust_asset.name,
        issuer: trust_asset.issuer,
        format: trust_asset.format,
        expires_at: trust_asset.expires_at,
        consumer: trust_asset.consumer,
        description: trust_asset.description,
        reminder_days: trust_asset.reminder_days,
        environment: trust_asset.environment&.name
      }
    end
  end

  def index_to_meilisearch
    task = self.index! 
    MeiliSearch::Rails.client.wait_for_task(task.first.metadata["taskUid"])
  end

  meilisearch enqueue: false do
    add_attribute :id
    add_attribute :name
    add_attribute :expires_at
    add_attribute :issuer
    add_attribute :format
    add_attribute :consumer
    
    add_attribute :workspace_id do
      workspace&.id
    end
    add_attribute :environment_id do
      environment&.id
    end

    searchable_attributes [ :name, :expires_at, :issuer, :format, :consumer, :workspace_id, :environment_id ]
    
    # Optionnel : Champs utilisables pour le filtrage (facets)
    filterable_attributes [ :name, :expires_at, :issuer, :format, :consumer, :workspace_id, :environment_id, :expires_at ]
  end  

  def self.cost
    self.count * Cost.find('TrustAsset').credits
  end
end
