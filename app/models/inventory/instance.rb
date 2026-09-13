class Inventory::Instance < ApplicationRecord
  include MeiliSearch::Rails
  extend Pagy::Search
  belongs_to :workspace
  belongs_to :environment
  belongs_to :model_category, class_name: 'Inventory::ModelCategory'
  has_many :instance_attrs, class_name: 'Inventory::InstanceAttr', dependent: :destroy
  enum :status, { active: 0, deleted: 1 }
  attr_accessor :workspace_ids, :environment_ids, :model_category_ids, :model_family_ids

  meilisearch do
    add_attribute :id
    add_attribute :name
    add_attribute :uuid
    add_attribute :status
    
    add_attribute :model_category_id do
      model_category&.id
    end
    add_attribute :model_category_name do
      model_category&.name
    end
    add_attribute :model_category_resource_type do
      model_category&.resource_type
    end
    attribute :model_family_id do
      model_category&.model_family&.id
    end
    add_attribute :workspace_id do
      workspace&.id
    end
    add_attribute :environment_id do
      environment&.id
    end
    add_attribute :project_id do
      workspace.project&.id
    end
    add_attribute :organization_id do
      workspace.project&.organization&.id
    end
    searchable_attributes [ :name, :model_category_name, :status ]
    filterable_attributes [ :status, :workspace_id, :model_family_id, :environment_id, :model_category_id, :project_id, :organization_id ]
  end

  def attrs
    instance_attrs.each do |attr|
      yield attr.model_category_attr.name, attr.value
    end
  end
end
