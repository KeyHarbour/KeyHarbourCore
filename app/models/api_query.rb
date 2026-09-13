class ApiQuery < LogsRecord
  require "csv"
  require "fileutils"
  belongs_to :serviceable, polymorphic: true  
  enum :service_name, Cost.service_names

  default_scope { order(date: :asc) }

  def self.count_by_organization(organization, start_time, end_time)
    return if organization.nil?
    
    tokens = organization.tokens.pluck(:id) + organization.projects.joins(:tokens).pluck('tokens.id') + organization.workspaces.joins(:tokens).pluck('tokens.id')
    ApiQuery.where(token: tokens, created_at: start_time..end_time).count
  end

  def self.count_by_organizations(organizations, start_time, end_time)
    return if organizations.nil?
    total = 0
    organizations.each do |organization|
      tokens = organization.tokens.pluck(:id) + organization.projects.joins(:tokens).pluck('tokens.id') + organization.workspaces.joins(:tokens).pluck('tokens.id')
      total += ApiQuery.where(token: tokens, created_at: start_time..end_time).count
    end
    total
  end

  def self.build_from_last_date
    api_query = ApiQuery.all.first 
    return nil unless api_query.present?

    date = api_query.date.to_date
    return nil if date == Date.current

    all_queries = ApiQuery.where(date: api_query.date.all_day)
    
    all_queries.push_to_workspace_queries(date)
    all_queries.push_to_project_queries(date)
    all_queries.export_csv(date)
    Account.calculate_usage(date)
    Account.build_montly(date)
    date
  end

  def self.export_csv(date)
    logger.debug "Exporting API queries to CSV"
    logger.debug "Total API queries: #{self.count}"
    attributes = %w[id token serviceable_type serviceable_id controller action date]
    dir_path = Rails.root.join("storage", "logs", "2026")
    FileUtils.mkdir_p(dir_path)
    file_path = Rails.root.join("storage", "logs", "2026", "#{date}.csv")
    CSV.open(file_path, "wb", write_headers: true, headers: attributes) do |csv|
      self.find_each do |api_query|
        csv << attributes.map { |attr| api_query.send(attr) }
      end
    end
    self.delete_all
  end

  def self.cost(service_name)
    self.where(service_name: service_name).count * Cost.find(service_name).credits
  end
end
