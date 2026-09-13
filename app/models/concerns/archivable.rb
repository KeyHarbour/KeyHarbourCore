module Archivable
  extend ActiveSupport::Concern

  included do
    enum :status, { active: 0, disabled: 1, archived: 2 }
    scope :active,          -> { where(status: statuses[:active]) }
    scope :not_archived,    -> { where.not(status: statuses[:archived]) }
    scope :disabled,        -> { where(status: statuses[:disabled]) }
    scope :archived,        -> { where(status: statuses[:archived]) }
    before_update :prevent_modification_if_previously_archived
  end

  def active?
    status == "active"
  end

  def disabled?
    status == "disabled"
  end

  def archived?
    status == "archived"
  end

  private
  def prevent_modification_if_previously_archived
    return unless status_was == "archived"
    allowed_changes = %w[status archived_at updated_at]
    forbidden_changes = changed - allowed_changes

    if forbidden_changes.any?
      errors.add(:base, I18n.t('models.concerns.archivable.archived_item_error', changes: forbidden_changes.join(', ')))
      throw :abort
    end
  end
end