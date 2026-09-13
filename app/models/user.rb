class User < ApplicationRecord
  WRITER_ROLE = %i[admin editor]
  READER_ROLE = %i[admin editor viewer]
  has_secure_password
  include MeiliSearch::Rails
  has_many :sessions, dependent: :destroy
  has_many :team_users
  has_many :teams, through: :team_users
  has_many :organization_team_roles, -> { where(resource_type: 'Organization') }, through: :teams, source: :team_roles
  has_many :account_organizations, through: :organization_team_roles, source: :resource, source_type: 'Organization'
  has_many :organization_projects, through: :account_organizations, source: :projects
  has_many :organization_workspaces, through: :organization_projects, source: :workspaces

  has_many :project_team_roles, -> { where(resource_type: 'Project') }, through: :teams, source: :team_roles
  has_many :account_projects, through: :project_team_roles, source: :resource, source_type: 'Project'
  has_many :project_organizations, through: :account_projects, source: :organization
  has_many :project_workspaces, through: :project_organizations, source: :workspaces
  
  has_many :workspace_team_roles, -> { where(resource_type: 'Workspace') }, through: :teams, source: :team_roles  
  has_many :account_workspaces, through: :workspace_team_roles, source: :resource, source_type: 'Workspace'
  has_many :workspace_projects, through: :account_workspaces, source: :project  
  has_many :workspace_organizations, through: :workspace_projects, source: :organization  
           
  has_many :model_categories, through: :organizations, class_name: "Inventory::ModelCategory"
  has_many :model_category_attrs, through: :model_categories
  has_many :model_families, through: :organizations
  has_many :project_tokens, through: :account_organizations, source: :project_tokens
  has_many :organization_tokens, through: :account_organizations, source: :tokens
  has_many :projects, through: :account_organizations
  has_many :workspaces, through: :projects
  has_one :account_user, dependent: :destroy
  has_one :account, through: :account_user
  has_many :notifications, as: :recipient, dependent: :destroy
  validates :email_address, presence: true, uniqueness: { case_sensitive: false }
  accepts_nested_attributes_for :account_user, reject_if: :all_blank, allow_destroy: true
  
  before_save :do_something_if_email_changed, if: :will_save_change_to_email_address?
 
  enum :global_role, { admin: 0, default: 254, desactivated: 255 }
  attr_accessor :account_name

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def initiate_email_verification
    return unless saved_change_to_email_address?

    email_change = EmailChange.create(user: self, from: nil, to: email_address)
    token = email_change.generate_token_for :email_change
    UserMailer.verify_email(email_change, token).deliver_later
  end

  def role
    return nil unless account_user
    account_user.role
  end

  def workspace_list(project)
    project.workspaces.each do |workspace|
      return true if READER_ROLE.include? workspace_permissions(workspace)
    end
    false
  end

  def workspace_edit(workspace)
    return true if WRITER_ROLE.include? workspace_permissions(workspace)
    false
  end

  def workspace_view(workspace)
    return true if READER_ROLE.include? workspace_permissions(workspace)
    false
  end

  def workspace_permissions(workspace)
    return :admin if account_admin?

    roles = self.workspace_team_roles.where(resource: workspace).map(&:role).uniq || []

    project_roles = project_permissions(workspace.project) || []
    TeamRole.greater(roles + [ project_roles ])
  end

  def project_edit(project)
    return true if WRITER_ROLE.include? project_permissions(project)
    false
  end

  def project_view(project)
    return true if READER_ROLE.include? project_permissions(project)
    false
  end

  def project_permissions(project)
    return :admin if account_admin?

    roles = self.project_team_roles.where(resource: project).map(&:role).uniq || []
    organization_roles = organization_permissions(project.organization) || []
    TeamRole.greater(roles + [ organization_roles ])
  end

  def organization_edit(organization)
    return true if WRITER_ROLE.include? organization_permissions(organization)
    false
  end

  def organization_view(organization)
    return true if READER_ROLE.include? organization_permissions(organization)
    false
  end

  def organization_permissions(organization)
    return :admin if account_admin?

    roles = self.organization_team_roles.where(resource: organization).map(&:role).uniq
    TeamRole.greater(roles)
  end

  def name
    email_address
  end

  def full_name
    email_address.split('@').first.titleize
  end

  def self.from_omniauth(auth)
    logger.info "# 1. On cherche par UID/Provider OU par Email".green
    user = find_by(provider: auth.provider, uid: auth.uid) || find_by(email_address: auth.info.email)

    if user
      logger.info "# 2. On met à jour les infos si nécessaire (ex: premier lien avec Google)".green
      # 2. On met à jour les infos si nécessaire (ex: premier lien avec Google)
      user.update(uid: auth.uid, provider: auth.provider)
    else
      # 3. Création d'un nouvel utilisateur
      logger.info "# 3. Création d'un nouvel utilisateur".green
      user = create do |u|
        u.email_address = auth.info.email
        u.name = auth.info.name
        u.uid = auth.uid
        u.provider = auth.provider
        u.password = SecureRandom.hex(16) # Mot de passe aléatoire inutilisé
      end
    end
    user
  end

  def account_admin?
    return true if self.admin?

    return true if account_user && account_user.role == Role.find_by(name: 'Owner') || account_user.role == Role.find_by(name: 'Admin')
    false
  end

  meilisearch do
    add_attribute :id
    add_attribute :email_address
    add_attribute :global_role
    add_attribute :account_id do
      account&.id
    end
    add_attribute :account_name do
      account&.name
    end
    add_attribute :account_role_name do
      account_user&.role&.name
    end
    searchable_attributes [ :email_address, :global_role, :account_name, :account_role_name ]
    filterable_attributes [ :email_address, :global_role, :account_name, :account_role_name ]
  end

  private

  def do_something_if_email_changed
    return if self.email_verified == false
    
    self.email_verified = false
    save
  end 
end
