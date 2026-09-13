class Inventory::ModelCategoryAttr < ApplicationRecord
  include MeiliSearch::Rails
  belongs_to :model_category, class_name: 'Inventory::ModelCategory'
  has_many :instance_attrs, class_name: 'Inventory::InstanceAttr', dependent: :destroy

  meilisearch do
    add_attribute :id
    add_attribute :name
    add_attribute :attr_name
    add_attribute :active
    add_attribute :model_category_id do
      model_category&.id
    end
    searchable_attributes [ :name, :attr_name, :active, :model_category_id ]
    filterable_attributes [ :name, :attr_name, :active, :model_category_id ]
  end
end
