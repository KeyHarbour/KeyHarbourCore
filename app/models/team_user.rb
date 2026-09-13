class TeamUser < ApplicationRecord
  belongs_to :team
  belongs_to :user

  enum :role, {
    admin: 0,
    member: 1
  }

  validates :role, presence: true  
  
  validates :user_id, uniqueness: { scope: :team_id }
end
