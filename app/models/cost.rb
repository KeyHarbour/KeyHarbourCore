class Cost
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :id, :string
  attribute :service_type, :string, default: 'query'
  attribute :credits, :decimal, precision: 6, scale: 0

  DATA_PATH = Rails.root.join("config", "cost_data.yml")
  
  def self.all
    @all ||= begin
      yaml_data = YAML.load_file(DATA_PATH)
      yaml_data.map { |attributes| new(attributes) }
    end
  end

  def self.service_names
    all.index_by { |cost| cost.id.underscore }.transform_values(&:id)
  end

  def self.query_service_names
    service_names = []
    self.all.each do |cost|
      service_names << cost.id if cost.service_type == 'query'
    end
    service_names
  end

  def self.montly_service_names
    service_names = []
    self.all.each do |cost|
      service_names << cost.id if cost.service_type == 'monthly'
    end
    service_names
  end

  def self.find(id)
    all.find { |record| record.id == id.to_s } || raise(ActiveRecord::RecordNotFound)
  end

  def self.where(filters)
    all.select do |record|
      filters.all? { |key, value| record.send(key) == value }
    end
  end
end