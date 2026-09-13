class Statefile < ApplicationRecord
  belongs_to :workspace
  belongs_to :environment
  has_one :statefile_tag, dependent: :destroy
  encrypts :content
  before_create :assign_uuid
  after_save :fix_cost
  after_save :save_inventory
  validates :uuid, uniqueness: { scope: [ :workspace_id ] }
  default_scope { order(published_at: :desc) }
  before_save :set_default_content

  def set_default_content
    if content.nil? || content.empty? || content == ''
      self.content = '{ "version": 4, "resources": [] }'
    end
  end

  def size
    content.size
  end

  def self.new_version(workspace:, environment:, content:, published_at: nil)
    raise ActiveRecord::RecordNotFound, "Environment not available for this workspace" unless workspace.project.environments.include?(environment)

    workspace.statefiles.create(environment: environment, content: content, published_at: published_at || DateTime.now)
  end

  def pretty_instance(instance)
    (instance["sensitive_attributes"] || []).each do |sensitive_attribute|
      sensitive_attribute.each do |item|
        instance["attributes"][item["value"]] = "**SENSITIVE**"
      end
    end

    result = JSON.pretty_generate(instance)
    result
  end

  def pretty_content
    JSON.pretty_generate(parsed_content)
  rescue JSON::ParserError
    "{}"
  end

  def pretty_content=(value)
    self.content = value
  end

  def lines_count
    pretty_content.lines.count
  end

  def resource_count
    begin
      return 0 unless content.present? && parsed_content["resources"].present?

      parsed_content["resources"].try(:count)
    rescue ActiveRecord::Encryption::Errors::Decryption => e
      logger.debug "ResourceCount Error #{e}"
      0
    end
  end

  def parsed_content
    JSON.parse(content)
  rescue JSON::ParserError
    {}
  end

  def tf_resources
    parsed_content["resources"] || []
  end

  def tf_outputs
    parsed_content["outputs"] || []
  end

  def self.resource_count
    total = 0
    self.all.each do |statefile|
      total += statefile.resource_count
    end
    total
  end

  private

  def save_inventory
    logger.debug "Updating Inventory".green
    InventoryService.new(workspace, environment, parsed_content).extract
  end

  def fix_cost
    workspace.fix_cost(environment: self.environment)
  end

  def assign_uuid
    return unless self.uuid.nil?

    self.uuid = UniqueNamesGenerator::Generator.new([ :colors, :adjectives, :animals ]).generate
    self.uuid += "-" + DateTime.now.to_i.to_s
    self.published_at = DateTime.now if self.published_at.nil?
  end
end
