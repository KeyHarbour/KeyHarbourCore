class Team < ApplicationRecord
  include MeiliSearch::Rails
  include Uuidable
  belongs_to :account
  has_many :team_users
  has_many :users, through: :team_users
  has_many :team_roles, dependent: :destroy
  validates :name, presence: true, uniqueness: { scope: :account_id }
  validates :account, presence: true
  attr_accessor :organization_id, :project_id, :workspace_id
  enum :source, { local: 0, active_directory: 1 }
  # before_validation :assign_default_account, on: :create

  def to_param
    uuid
  end

  meilisearch do
    add_attribute :id
    add_attribute :name
    add_attribute :uuid
    add_attribute :description
    add_attribute :source
    add_attribute :account_id
    searchable_attributes [ :name, :uuid, :description, :source, :account_id ]
    filterable_attributes [ :name, :uuid, :description, :source, :account_id ]
  end

  private

  # def assign_default_account
  #   self.account ||= Account.first
  # end
end
