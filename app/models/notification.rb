class Notification < ApplicationRecord
  # Associations polymorphiques
  belongs_to :recipient, polymorphic: true

  # Scopes pour filtrer facilement
  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :recent, -> { order(created_at: :desc).limit(5) }

  # Méthodes d'action
  def read?
    read_at.present?
  end

  def unread?
    read_at.nil?
  end  

  def mark_as_read!
    update!(read_at: Time.current)
  end
end
