class License::Upload < ApplicationRecord
  belongs_to :instance, class_name: 'License::Instance'
  has_one_attached :file
  has_one_attached :log
  enum :status, { queued: 0, processing: 1, cancel: 2, done: 3 }
  after_create :queue_item

  def queue_item
    self.status = :queued
    self.save
    ProcessFileJob.perform_later(upload: self)
  end  
end
