class KeyValueStore < ApplicationRecord
  VALID_FORMAT_REGEX = /\A[A-Za-z0-9\.\-\_]+\z/
  include MeiliSearch::Rails
  belongs_to :workspace
  belongs_to :environment
  validates :key, presence: true, 
                  uniqueness: { scope: [ :workspace_id, :environment_id ] },
                  format: { 
                    with: VALID_FORMAT_REGEX,
                    message: "only allows numbers, dots, dashes, and underscores" 
                  }
  has_one_attached :value_file
  before_validation :downcase_fields
  scope :active, -> { where("expires_at >= ? OR expires_at IS NULL", Time.current) }
  scope :for_environment, ->(env) { where(environment: env).includes(:environment) }
  after_save :index_to_meilisearch
  validate :at_least_one_value_present

  def value_file=(content)
    return if content.nil?
    super(content)
    self.value = nil
  end

  def value=(content)
    return if content.nil?
    super(content)
    self.value_file = nil
  end


  def index_to_meilisearch
    task = self.index! 
    MeiliSearch::Rails.client.wait_for_task(task.first.metadata["taskUid"])
  end

  meilisearch enqueue: false do
    add_attribute :id
    add_attribute :key
    add_attribute :expires_at
    add_attribute :private
    add_attribute :one_time_only
    
    add_attribute :workspace_id do
      workspace&.id
    end
    add_attribute :environment_id do
      environment&.id
    end

    searchable_attributes [ :key, :expires_at, :workspace_id, :environment_id ]

    filterable_attributes [ :key, :workspace_id, :environment_id, :expires_at, :one_time_only, :private ]
  end  

  def self.as_json_api(relation)
    relation.map do |kv|
      {
        key: kv.key,
        value: kv.value,
        expires_at: kv.expires_at,
        private: kv.private,
        environment: kv.environment&.name
      }
    end
  end

  private

  def downcase_fields
    # self.key = key&.downcase
  end

  def at_least_one_value_present
    if value.blank? && value_file.blank?
      errors.add(:base, "value or value_file should not be empty")
    end
    if value.present? && value_file.present?
      errors.add(:base, "one of value or value_file should be empty")
    end
  end
end
