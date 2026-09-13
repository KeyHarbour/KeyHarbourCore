class Workspace < ApplicationRecord
  include Archivable
  include Meilisearch::Rails
  belongs_to :project

  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings
  has_many :tokens, as: :scopable, dependent: :destroy

  has_many :statefiles, dependent: :destroy
  has_many :key_value_stores, dependent: :destroy
  has_many :instances, class_name: 'Inventory::Instance', foreign_key: 'workspace_id'
  has_one :statefile_lock, dependent: :destroy
  has_many :team_roles, as: :resource
  has_many :trust_assets, dependent: :destroy

  has_many :usage_daily_workspaces, dependent: :destroy
  validates :name, presence: true, length: { minimum: 3 }, uniqueness: { scope: :project_id, case_sensitive: false }
  
  before_create :assign_uuid
  # before_validation :lower_case
  scope :current_user, ->(current) { where(id: current.workspace_ids) }

  def environments
    project.environments
  end

  def organization
    project.organization
  end

  def full_name
    "#{project.name} / #{name}"
  end

  def statefiles_json(environment:)
    statefiles.where(environment: environment).pluck(:uuid, :content, :published_at).map { |sf_uuid, sf_content, sf_published_at| { uuid: sf_uuid, content: sf_content, published_at: sf_published_at } }
  end

  def to_param
    uuid
  end

  def trust_assets_by_env(environment, published_at: nil)
    trust_assets.where(environment: project.environments.find_by(name: environment))
  end

  def key_values_by_env(environment)
    key_value_stores.where(environment: project.environments.find_by(name: environment))
  end

  def statefiles_by_env(environment, published_at: nil)
    raise ActiveRecord::RecordNotFound, "Environment not available for this workspace" if project.environments.where(name: environment).count == 0

    statefiles.find_or_initialize_by(environment: project.environments.find_by(name: environment))
  end

  def key_values_by_env(environment)
    key_value_stores.where(environment: project.environments.find_by(name: environment))
  end

  def tf_resources
    return 0 if statefiles.count == 0
    result = 0
    project.environments.each do |environment|
      result += statefiles_by_env(environment.name).resource_count
    end
    result
  end

  def size
    return 0 if statefiles.count == 0
    result = 0
    project.environments.each do |environment|
      result += statefiles_by_env(environment.name).size
    end
    result
  end

  def last_update
    last = nil 
    statefiles.each do |statefile|
      last = statefile.published_at if last.nil?
      last = statefile.published_at if statefile.published_at && last < statefile.published_at
    end
    last
  end

  def fix_cost(environment:)
    last_statefile = statefiles.where(environment: environment).order(published_at: :desc).first
    workspace_environment = WorkspaceEnvironment.where(workspace: self, environment: environment).first_or_create
    logger.debug "Fixing workspace cost for statefile #{id}"
  end

  meilisearch do
    attribute :name, :uuid, :status, :project_id, :id

    searchable_attributes [ :name, :uuid ]
    filterable_attributes [ :name, :uuid, :status, :organization_id, :id ]
    sortable_attributes [ :created_at ]
  end

  private

  def assign_uuid
    self.uuid = SecureRandom.uuid
  end
  #
  # def lower_case
  #   self.name = (name || "").downcase.gsub(/[^a-z0-9]/, "")
  # end
end
