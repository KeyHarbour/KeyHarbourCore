class TeamRole < ApplicationRecord
  belongs_to :team
  belongs_to :resource, polymorphic: true

  enum :role, {
    viewer: 0,    # ki-eye
    editor: 1,    # ki-pencil
    admin: 2      # ki-crown-2
  }

  validates :role, presence: true
  
  def role_icon
    case name
    when "viewer"
      "ki-eye"
    when "editor"
      "ki-pencil"
    when "admin"
      "ki-crown-2"
    else
      "ki-eye" # Default icon
    end
  end

  def organization_id=(value)
    self.resource = Organization.find_by(id: value)
  end

  def workspace_id=(value)
    self.resource = Workspace.find_by(id: value)
  end

  def project_id=(value)
    self.resource = Project.find_by(id: value)
  end

  def self.greater(roles)
    return :admin if roles.any? { |r| r.to_s == "admin" }
    return :editor if roles.any? { |r| r.to_s == "editor" }
    return :viewer if roles.any? { |r| r.to_s == "viewer" }
    nil
  end
end
