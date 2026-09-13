class Inventory::ModelFamily < ApplicationRecord
  include MeiliSearch::Rails
  belongs_to :organization
  has_many :model_categories, class_name: 'Inventory::ModelCategory', dependent: :destroy

  after_commit :reindex_items

  # private

  def reindex_items
    model_categories.reindex!
  end

  meilisearch do
    add_attribute :id
    add_attribute :name
    add_attribute :organization_id do
      organization&.id
    end
    searchable_attributes [ :name, :organization_id ]
    filterable_attributes [ :name, :organization_id ]
  end
end
