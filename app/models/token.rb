class Token < ApplicationRecord
  include Meilisearch::Rails
  belongs_to :scopable, polymorphic: true
  belongs_to :environment, optional: true
  validates :name, presence: true, uniqueness: { scope: %i[scopable_type scopable_id] }
  validates :expiration, presence: true
  validates :scopable_type, presence: true
  validates :scopable_id, presence: true
  attr_reader :project_id, :workspace_id, :organization_id

  generates_token_for :statefile do
    updated_at
  end

  def organization_id=(value)
    return if value.blank?
    return if [ "Project", "Workspace" ].include?(scopable_type)
    self.scopable_type = "Organization"
    self.scopable_id = value
  end

  def workspace_id=(value)
    return if value.blank?
    self.scopable_type = "Workspace"
    self.scopable_id = value
  end

  def project_id=(value)
    return if value.blank?
    return if scopable_type == "Workspace"
    self.scopable_type = "Project"
    self.scopable_id = value
  end

  def get_expire_in
    (expiration - Time.current).to_i
  end

  def self.find_workspace_by_token(workspace_uuid, token_str)
    token = Token.check(token_str)
    return nil if token.nil?

    logger.debug "Token found: #{token}"
    if token.scopable_type == "Project"
      @project = token.scopable
      return @project.workspaces.find_by(uuid: workspace_uuid)
    elsif token.scopable_type == "Organization"
      @organization = token.scopable
      return @organization.workspaces.find_by(uuid: workspace_uuid)
    elsif token.scopable_type == "Workspace"
      @workspace = token.scopable
      return @workspace if @workspace.uuid.downcase == workspace_uuid.downcase
    end
    nil
  end

  def project_token?
    scopable_type == "Project"
  end

  def organization_token?
    scopable_type == "Organization" && !environment.nil?
  end

  def workspace_token?
    scopable_type == "Workspace"
  end

  def application_token?
    scopable_type == "Organization" && environment.nil?
  end

  def self.check(token_str)
    token = Token.find_by_token_for(:statefile, token_str)
    return nil unless token && token.expiration > Time.current
    
    token
  end

  meilisearch do
    attribute :name, :scopable_id, :scopable_type

    add_attribute :scopable_name do
      scopable&.name
    end

    searchable_attributes [ :name ]
    filterable_attributes [ :scopable_name, :scopable_type, :name ]
    sortable_attributes [ :created_at, :name, :scopable_type ]
  end
end
