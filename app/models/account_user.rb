class AccountUser < ApplicationRecord  
  belongs_to :user, inverse_of: :account_user
  belongs_to :account
  belongs_to :role
  default_scope { where.not(role: Role.find_by(name: 'disabled')) }
  after_save :index_parent_in_meilisearch

  def index_parent_in_meilisearch
    user.index!
  end
end
