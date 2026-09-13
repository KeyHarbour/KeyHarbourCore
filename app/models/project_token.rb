class ProjectToken < Token
  self.table_name = 'tokens'
  attr_accessor :only_project
  # self.inheritance_column = :_type_disabled

  validates :environment, presence: true

  def workspace_id=(value)
    @workspace_id = value
    self.scopable = Workspace.find_by(id: value)
  end

  meilisearch do
    attribute :name, :scopable_id, :scopable_type

    add_attribute :scopable_name do
      scopable&.name
    end

    add_attribute :environment_id do
      environment&.id
    end

    add_attribute :workspace_id do
      if scopable_type == "Workspace"
        scopable&.id
      else
        nil
      end
    end

    searchable_attributes [ :name ]
    filterable_attributes [ :scopable_name, :scopable_type, :name, :environment_id, :workspace_id ]
    sortable_attributes [ :created_at, :name, :scopable_type ]
  end
end
