class Environment < ApplicationRecord
  include Meilisearch::Rails
  belongs_to :organization
  has_and_belongs_to_many :projects
  has_many :workspace_environments, dependent: :destroy
  has_many :workspaces, through: :workspace_environments
  has_many :key_value_stores, dependent: :destroy
  has_many :statefiles, dependent: :destroy
  validates :name, presence: true, uniqueness: { scope: [ :organization_id ], case_sensitive: false }



  meilisearch do
    attribute :name, :active, :organization_id, :id

    searchable_attributes [ :name, :active, :organization_id, :id ]
    filterable_attributes [ :name, :active, :organization_id, :id ]
    sortable_attributes [ :created_at ]
  end
end
