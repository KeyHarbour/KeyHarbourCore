class Notification < ApplicationRecord
  belongs_to :recipient, polymorphic: true

  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :recent, -> { order(created_at: :desc).limit(5) }

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
