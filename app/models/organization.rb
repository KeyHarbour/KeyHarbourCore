class Organization < ApplicationRecord
  include Archivable
  include MeiliSearch::Rails

  has_many :projects, dependent: :destroy
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings

  has_many :usage_daily_projects, through: :projects
  has_many :usage_daily_organizations, dependent: :destroy
  has_many :workspaces, through: :projects
  has_many :statefiles, through: :workspaces

  has_many :trust_assets, through: :workspaces
  has_many :key_value_stores, through: :workspaces
  has_many :instances, class_name: 'Inventory::Instance', through: :workspaces
  has_many :instance_attrs, class_name: 'Inventory::InstanceAttr', through: :instances
  has_many :project_tokens, through: :projects, source: :tokens
  has_many :tokens, as: :scopable, dependent: :destroy

  has_many :environments, dependent: :destroy
  has_many :model_categories, class_name: 'Inventory::ModelCategory', foreign_key: 'organization_id'
  has_many :model_category_attrs, through: :model_categories
  has_many :model_families, class_name: 'Inventory::ModelFamily', foreign_key: 'organization_id'
  has_many :team_roles, as: :resource
  has_many :teams, through: :team_roles
  has_many :organization_histories

  has_many :applications, class_name: 'License::Application', dependent: :destroy
  has_many :app_instances, through: :applications, source: :app_instances
  has_many :licensees, class_name: 'License::Licensee', through: :app_instances
  has_many :app_team_members, class_name: 'License::TeamMember', dependent: :destroy
  belongs_to :account
  default_scope { active.order(name: :asc) }
  scope :current_user, ->(current) { where(id: current.organization_ids) }

  validates :name, presence: true
  before_create :assign_uuid

  def to_param
    uuid
  end

  meilisearch do
    add_attribute :id
    add_attribute :name
    add_attribute :uuid
    add_attribute :description
    add_attribute :status
    add_attribute :account_id
    searchable_attributes [ :name, :uuid, :description, :status, :account_id ]
    filterable_attributes [ :name, :uuid, :description, :status, :account_id ]
  end

  def projects_json
    projects.pluck(:uuid, :name).map { |uuid, name| { uuid: uuid, name: name } }
  end

  def api_queries(start_date = 30.days.ago, end_date = Time.current)
    ApiQuery.count_by_organization(self, start_date, end_date)
  end

  def statefile_size
    total = 0
    workspaces.each do |workspace|
      workspace.statefiles.each do |statefile|
        begin
          total += statefile.content&.size.to_i
        rescue ActiveRecord::Encryption::Errors::Decryption
          # On ignore le fichier si on ne peut pas le décrypter
          next
        end
      end
    end
    total
  end

  def renewals
    result = []
    applications.active.each do |application|
      next unless application.renewal_date.present?

      result << {
        application: application,
        logo: application.logo,
        name: "#{application.name}",
        renewal_date: application.renewal_date,
        alert_renewal_2: application.alert_renewal_2,
        alert_renewal_1: application.alert_renewal_1
      }
    end
    result.sort_by { |item| item[:renewal_date] }
  end

  def keyvalue_size
    0
  end

  def apps_json
    applications.map do |app|
      {
        uuid: app.uuid,
        name: app.name,
        short_name: app.short_name,
        vendor: app.vendor,
        owner: app.owner,
        tier: app.tier,
        renewal_date: app.renewal_date&.to_s,
        status: app.status
      }
    end
  end

  def cost
    0
  end

  def self.cost
    0
  end

  def all_tokens
    Token.where(scopable: [ self, projects, workspaces ]).order(expiration: :asc)
  end

  private

  def assign_uuid
    self.uuid = SecureRandom.uuid
  end
end
