class Project < ApplicationRecord
  include Archivable
  include Uuidable
  include Meilisearch::Rails
  belongs_to :organization
  has_many :workspaces, dependent: :destroy
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings

  has_many :usage_daily_workspaces, through: :workspaces
  has_many :usage_daily_projects, dependent: :destroy

  has_many :trust_assets, through: :workspaces
  has_many :key_value_stores, through: :workspaces
  has_many :tokens, as: :scopable, dependent: :destroy
  has_many :project_tokens, as: :scopable, dependent: :destroy
  has_many :statefiles, through: :workspaces

  has_many :team_roles, as: :resource
  has_and_belongs_to_many :environments, before_add: :validates_environment

  validates :name, presence: true
  default_scope { not_archived.order(name: :asc) }

  scope :current_user, ->(current) { where(id: current.project_ids) }

  def validates_environment(environment)
    raise ActiveRecord::Rollback if self.environments.include? environment
  end

  def full_name
    "#{organization.name} / #{name}"
  end

  def to_param
    uuid
  end   
  
  def environment_names
    environments.pluck(:name)
  end

  def workspaces_json
    workspaces.pluck(:uuid, :name).map { |uuid, name| { uuid: uuid, name: name } }
  end

  def all_tokens
    ProjectToken.where(scopable: [ self, workspaces ])
  end

  meilisearch do
    attribute :name, :uuid, :status, :organization_id, :id

    searchable_attributes [ :name, :uuid, :status, :organization_id, :id ]
    filterable_attributes [ :name, :uuid, :status, :organization_id, :id ]
    sortable_attributes [ :created_at ]
  end

  private
end
