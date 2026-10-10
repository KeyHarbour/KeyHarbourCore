class TokenWorkspace < Token
  validate :ensure_correct_scopable_type
  belongs_to :environment

  def workspace
    scopable
  end

  def self.find_workspace_by_token(workspace_uuid, token_str)
    token = Token.check(token_str)
    return nil if token.nil?

    return nil if token.workspace.uuid.downcase != workspace_uuid.downcase

    token.workspace 
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
    unless scopable.is_a?(Workspace)
      errors.add(:scopable, "must be a Workspace")
    end
  end  
end