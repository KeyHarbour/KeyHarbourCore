class InventoryService
  def initialize(workspace, environment, content)
    @workspace = workspace
    @environment = environment
    @content = content
    create_default
    Rails.logger.debug "Importing data for inventory"
    @items = Inventory::Instance.where(workspace: @workspace, environment: @environment).all.to_a
    # @items = []
  end

  def create_default
    @unclassified = @workspace.organization.model_families.find_or_create_by(name: "Unclassified")
  end

  def extract
    all_items = []
    Rails.logger.debug @content
    return nil unless @content["resources"]
    @content["resources"].each do |resource|
      next unless resource.include? "instances"
      
      resource["instances"].each_with_index do |instance, index|
        all_items << set_item(resource["type"], "#{resource['name']}[#{index}]", instance)
      end
    end
    @items.each do |item|
      unless all_items.include?(item.id)
        item.update(status: 1)
      end
    end
    all_items
  end

  def model_category(resource_type)
    item = Inventory::ModelCategory.find_by(resource_type: resource_type, organization: @workspace.organization)
    return item if item
    Inventory::ModelCategory.create(name: resource_type, resource_type: resource_type, organization: @workspace.organization, model_family: @unclassified)
  end

  def build_model_category_attr(imc, instance)
    instance["attributes"].each do |attr_name, value|
      next if attr_name.downcase == "id"
      imc_attr = imc.model_category_attrs.find_or_create_by(attr_name: attr_name)
      imc_attr.update(name: attr_name.humanize, active: true) if imc_attr.name.blank?
    end
  end

  def set_item(resource_type, name, instance)
    imc = model_category(resource_type)
    attrs = build_model_category_attr(imc, instance)
    istance = imc.instances.find_or_create_by(workspace: @workspace, environment: @environment, uuid: instance["attributes"]["id"], name: name)
    istance.update(status: 0)

    imc.model_category_attrs.each do |model_category_attr|
      imc_attr = istance.instance_attrs.find_or_create_by(model_category_attr: model_category_attr)
      imc_attr.update(name: model_category_attr.name, value: instance["attributes"][model_category_attr.attr_name])
    end
    istance.id
  end
end