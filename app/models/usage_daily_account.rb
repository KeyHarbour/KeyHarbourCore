class UsageDailyAccount < ApplicationRecord
  belongs_to :account
  enum :service_name, Cost.service_names
  validates :service_name, presence: true
  validates :day, presence: true, uniqueness: { scope: [ :account_id, :service_name ] }

  def self.monthly_units(service, date)
    logger.debug "service_name: #{service}".red
    logger.debug "service_name: #{service.to_yaml}".red
    logger.debug "service type: #{service[:service_type]}".red
    if service[:service_type] == 'query'
      UsageDailyAccount.where(day: date, service_name: service[:id]).sum(:units)
    else
      UsageDailyAccount.where(day: date, service_name: service[:id]).maximum(:units)
    end
  end
end
