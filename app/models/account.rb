class Account < ApplicationRecord
  include MeiliSearch::Rails
  include Archivable
  has_many :account_users, dependent: :destroy
  has_many :account_histories, dependent: :destroy
  has_many :users, through: :account_users, dependent: :destroy
  has_many :organizations, dependent: :destroy

  has_many :usage_daily_organizations, through: :organizations
  has_many :usage_daily_accounts, dependent: :destroy
  has_many :usage_monthly_accounts, dependent: :destroy
  has_many :applications, through: :organizations

  has_many :app_team_members, through: :organizations
  has_many :model_categories, through: :organizations
  has_many :model_families, through: :organizations
  has_many :project_tokens, through: :organizations, source: :project_tokens
  has_many :organization_tokens, through: :organizations, source: :tokens
  has_many :projects, through: :organizations
  has_many :app_instances, through: :applications
  has_many :model_category_attrs, through: :model_categories
  has_many :teams, dependent: :destroy
  has_many :workspaces, through: :projects
  has_many :statefiles, through: :workspaces
  has_many :trust_assets, through: :workspaces
  has_many :key_value_stores, through: :workspaces
  has_many :account_monthlies
  has_one :subscription, dependent: :destroy
  has_many :subscription_credits, through: :subscription
  has_many :licensees, class_name: 'License::Licensee', through: :organizations
  # default_scope { active.order(name: :asc) }
  after_save :uuid
  after_create :add_free_credit, if: -> { ActiveRecord::Base.connection.table_exists?(:acount_histories) }
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :name, presence: true
  validates :country_code, presence: true
  validates :province_code, presence: true

  validates :billing_contact, 
            presence: true, 
            uniqueness: { case_sensitive: false }, 
            format: { with: VALID_EMAIL_REGEX }

  meilisearch do
    add_attribute :id
    add_attribute :name
    add_attribute :city
    add_attribute :country_code
    add_attribute :province_code
    add_attribute :billing_contact
    add_attribute :status
    add_attribute :plan
    searchable_attributes [ :name, :city, :country_code, :province_code, :billing_contact, :status, :plan ]
    filterable_attributes [ :name, :city, :country_code, :province_code, :billing_contact, :status, :plan ]
  end

  def self.meilisearch_indexable
    unscoped
  end

  def application_uniq_users
    users = []
    applications.each do |application|
      users += application.licensees.pluck(:uuid)
    end
    users.uniq
  end

  def uncompleted?
    Current.account.subscription.active != true
  end

  def add_free_credit
    free_plan = Plan.find('free')
    AccountHistory.create(account: self, queries: free_plan.credits, day: DateTime.now.to_date, is_credit: true, uuid: "free-#{DateTime.now.year}-#{DateTime.now.year}")
    self.users.each do |user|
      Notification.create!(
        recipient: user.id,
        message: "Welcome to KeyHarbour. You have been credited with #{free_plan.credits} API calls.",
        title: "Congratulation"
      )
    end
  end

  def api_queries(start_date = 30.days.ago, end_date = Time.current)
    total = 0
    organizations.each do |organization|
      total += organization.api_queries(start_date, end_date)
    end
    total
  end

  def uuid
    if super == nil && !country_code.nil?
      update_attribute(:uuid, "#{country_code}#{name[0..2]}#{sprintf('%04d', Account.where("name LIKE ?", "#{name[0..2]}%").count + 1)}".upcase)
    end
    super
  end

  def subscription
    super || self.create_subscription(account: self, plan_id: "free", current_period_start: Time.current.advance(days: -15), current_period_end: Time.current.advance(months: 1, days: -15))
  end

  def renewals
    result = []
    organizations.each do |organization|
      result += organization.renewals
    end
    result.sort_by { |item| item[:renewal_date] }
  end

  def owners
    account_users.where(role: Role.find_by(name: "Owner")).map(&:user)
  end

  def admins
    account_users.where(role: Role.find_by(name: "Admin")).map(&:user)
  end

  def viewers
    account_users.where(role: Role.find_by(name: "Viewer")).map(&:user)
  end

  def inactives
    account_users.where(role: Role.find_by(name: "Inactive")).map(&:user)
  end

  def description
    result = ""
    result += "#{address1}," if address1 && !address1.empty?
    result += " #{address2}," if address2 && !address2.empty?
    result += " #{city}," if city && !city.empty?
    result += " #{zip}," if zip   && !zip.empty?
    result += " #{province_code}," if province_code && !province_code.empty?
    result += " #{country_code}" if country_code && !country_code.empty?
    result.strip
  end
end
