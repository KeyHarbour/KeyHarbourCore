class TokenOrganization < Token
  include Meilisearch::Rails
  validate :ensure_correct_scopable_type
  belongs_to :environment

  def organization
    scopable
  end

  def self.find_workspace_by_token(workspace_uuid, token_str)
    token = Token.check(token_str)
    return nil if token.nil?

    return token.organization.workspaces.find_by(uuid: workspace_uuid)

    nil
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

  private

  def ensure_correct_scopable_type
    unless scopable.is_a?(Organization)
      errors.add(:scopable, "must be a Organization")
    end
  end  
end