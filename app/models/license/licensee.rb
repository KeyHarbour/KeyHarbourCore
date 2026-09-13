require 'csv'

class License::Licensee < ApplicationRecord
  include Archivable
  belongs_to :instance, class_name: 'License::Instance'
  validates :uuid, presence: true

  # def as_json(options = {})
  #   {
  #     id: self.id,           # D3 attend 'id'
  #     parent_id: self.manager_id, # D3 attend 'parent_id'
  #     name: self.uuid     # D3 attend 'name'
  #   }
  # end

  def import_file=(file)
    logger.debug "Importing licensees from file: #{file.original_filename}"
    revision = SecureRandom.uuid
    CSV.foreach(file.path, headers: true) do |row|
      licencee = License::Licensee.where(uuid: row['name'], instance: self.instance).first_or_initialize
      if row['last_access'].present?
        licencee.last_access = DateTime.parse(row['last_access'])
      end
      licencee.revision = revision
      licencee.save!
    end
    instance.licensees.where.not(revision: revision).destroy_all
  end

  def import_file
    
  end

  def self.calculate_total_costs(data)
    # 1. Préparation : On indexe par ID et on prépare les enfants
    nodes = {}
    children_map = Hash.new { |h, k| h[k] = [] }

    data.each do |item|
      nodes[item[:id]] = item.merge(total_cost: 0.0)
      children_map[item[:parent_id]] << item[:id] if item[:parent_id]
    end

    # 2. Définition de la fonction de calcul récursive via un PROC
    sum_logic = lambda do |id|
      node = nodes[id]
      current_cost = node[:cost].to_f
      
      # On calcule récursivement pour chaque enfant
      children_total = children_map[id].sum { |child_id| sum_logic.call(child_id) }
      
      total = current_cost + children_total
      node[:total_cost] = ActiveSupport::NumberHelper.number_to_currency(total, precision: 2)
      total
    end

    # 3. Lancement du calcul pour chaque racine (parent_id: nil)
    data.each do |item|
      if item[:parent_id].nil? || item[:parent_id] == ""
        sum_logic.call(item[:id])
      end
    end

    nodes.values
  end


  def self.add_member(result, instance, team_member, cost)
    result[team_member.id] = {
      id: team_member.id,
      parent_id: team_member.manager_id || 0,
      name: team_member.uuid,
      manager_name: team_member.manager&.uuid,
      cost: cost
      # cost: ActiveSupport::NumberHelper.number_to_currency(cost)
    }
    unless result[team_member.manager_id].present? || team_member.manager_id.nil?
      add_member(result, instance, team_member.manager, 0)
    end
  end

  def self.create_team_member(instance, uuid)
    instance.application.organization.app_team_members.create!(uuid: uuid)
  end

  def self.tree(instance)
    result = {
      "0" => {
        id: 0,
        name: "Org",
        cost: 0
      }
    }
    instance.licensees.each do |licensee|
      logger.debug "Licensee: #{licensee.uuid}".red
      team_member = instance.application.organization.app_team_members.find_by(uuid: licensee.uuid)
      team_member = create_team_member(instance, licensee.uuid) if team_member.nil?

      add_member(result, instance, team_member, instance.cost)
    end
    result.values
  end

  def self.cost
    self.pluck(:uuid).uniq.count * Cost.find('License').credits
  end
end
