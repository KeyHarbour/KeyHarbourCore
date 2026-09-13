module Uuidable
  extend ActiveSupport::Concern

  included do
    before_create :assign_uuid
  end

  private

  def assign_uuid
    self.uuid = SecureRandom.uuid
  end
end