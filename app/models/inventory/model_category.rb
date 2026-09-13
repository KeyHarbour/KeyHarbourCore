class Inventory::ModelCategory < ApplicationRecord
  include MeiliSearch::Rails  
  extend Pagy::Search
  belongs_to :organization
  belongs_to :model_family, class_name: 'Inventory::ModelFamily'
  has_many :instances, class_name: 'Inventory::Instance', dependent: :destroy
  has_many :model_category_attrs, class_name: "Inventory::ModelCategoryAttr", dependent: :destroy
  attr_accessor :model_family_ids
  after_commit :reindex_instances, if: -> { saved_change_to_name? || saved_change_to_resource_type? }

  meilisearch index_uid: "inventory_model_categories" do
    searchable_attributes [ :name, :resource_type, :organization_name, :model_family_name, :model_family_id ]
    filterable_attributes [ :active, :resource_type, :organization_id, :model_family_id ]
    attribute :organization_name do
      organization&.name
    end

    attribute :model_family_name do
      model_family&.name
    end

    attribute :model_family_id do
      model_family&.id
    end
    
    attribute :organization_id
    attribute :active
    attribute :resource_type
    attribute :name
  end

  private

  def reindex_instances
    Inventory::Instance.reindex!
  end  
end
