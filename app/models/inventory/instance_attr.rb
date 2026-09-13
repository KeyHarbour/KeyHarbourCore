class Inventory::InstanceAttr < ApplicationRecord
  include MeiliSearch::Rails
  belongs_to :instance, class_name: 'Inventory::Instance'
  belongs_to :model_category_attr, class_name: 'Inventory::ModelCategoryAttr'


  meilisearch do
    add_attribute :id
    add_attribute :name
    add_attribute :value
    add_attribute :instance_id do
      instance&.id
    end
    add_attribute :model_category_attr_id do
      model_category_attr&.id
    end
    searchable_attributes [ :name, :value, :instance_id, :model_category_attr_id ]
    filterable_attributes [ :name, :value, :instance_id, :model_category_attr_id ]
  end
end
