require 'csv'

class License::TeamMember < ApplicationRecord
  belongs_to :organization
  belongs_to :manager, class_name: 'License::TeamMember', optional: true
  has_many :members, class_name: 'License::TeamMember', foreign_key: 'manager_id', dependent: :nullify

  validates :uuid, presence: true, uniqueness: { scope: :organization_id }

  def manager_uuid
    manager&.uuid
  end

  def as_json(options = {})
    custom_json = {
      id: self.id,           # D3 attend 'id'
      parent_id: self.manager_id, # D3 attend 'parent_id'
      name: self.uuid     # D3 attend 'name'
    }
    super(options).merge(custom_json)
  end

  def import_file=(file)
    logger.debug "Importing team members from file: #{file.original_filename}"

    revision = SecureRandom.uuid
    CSV.foreach(file.path, headers: true) do |row|
      manager = License::TeamMember.find_by(uuid: row['manager_name'], organization_id: self.organization_id)
      team_member = License::TeamMember.where(uuid: row['name'], organization: self.organization).first_or_initialize
      team_member.manager = manager
      team_member.role = row['role']&.strip.presence || "N/A"
      team_member.revision = revision
      team_member.save!
      logger.debug team_member.revision
      logger.debug revision
      logger.debug team_member.to_json.to_yaml
      logger.debug team_member.errors.to_yaml
    end

    organization.app_team_members.where.not(revision: revision).destroy_all
    
  end

  def import_file
    
  end
end
