
class License::Provider < ApplicationRecord
  include MeiliSearch::Rails
  belongs_to :account
  has_many :quotes, class_name: 'License::Quote', foreign_key: 'provider_id'

  # Validations
  validates :name, presence: true
  validates :uuid, presence: true, uniqueness: { case_sensitive: false }

  private
  meilisearch do
    add_attribute :id
    add_attribute :name
    add_attribute :uuid
    add_attribute :account_id do
      account&.id
    end
    searchable_attributes [ :name, :uuid, :account_id ]
    filterable_attributes [ :name, :uuid, :account_id ]
  end  
end
