require 'whois'
require 'whois-parser'

class TrustAsset < ApplicationRecord
  VALID_FORMAT_REGEX = /\A[A-Za-z0-9._ -]+\z/
  include MeiliSearch::Rails
  belongs_to :workspace
  belongs_to :environment
  validates :name, presence: true, 
                  uniqueness: { scope: [ :workspace_id, :environment_id, :format ] },
                  format: { 
                    with: VALID_FORMAT_REGEX,
                    message: "only allows numbers, dots, dashes, and underscores" 
                  }
  validates :format, presence: true
  validates :issuer, presence: true, unless: :tls_certificate? && :domain?
  # validates :description, presence: true
  validates :consumer, presence: true, unless: :domain?
  validates :expires_at, presence: true, unless: :tls_certificate? && :domain?
  validate :expiration_date_cannot_be_in_the_past
  scope :active, -> { where("expires_at >= ? OR expires_at IS NULL", Time.current) }
  scope :for_environment, ->(env) { where(environment: env).includes(:environment) }
  after_save :index_to_meilisearch

  enum :format, {
    tls_certificate: 0,
    token: 1,
    domain: 2
  }

  def expiry_level
    # -1 no expiry data, 0 : no warning, 1 : warning, 2 : expired
    return -1 if expires_at.nil?
    return 2 if expires_at < DateTime.now
    return 1 if expires_at.advance(days: -reminder_days) <= DateTime.now
    0
  end

  def update_expiry
    if format == 'tls_certificate'
      details = ssl_certificate_details
      if details.nil?
        self.issuer = "Invalid domain name, cannot get the issuer"
      else
        self.expires_at = details[:expiry_date]
        self.issuer = details[:issuer_name]
      end
      return save
    end
    if format == 'domain'
      details = get_domain_expiration
      if details.nil?
        self.issuer = "Invalid domain name, cannot get the issuer"
      else
        self.expires_at = details[:expires_at]
        self.issuer = details[:registrar]
      end
      save
    end
  end

  def ssl_certificate_details
    uri = URI.parse("https://#{name}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http.open_timeout = 5
    http.read_timeout = 5

    http.start do |connection|
      cert = connection.peer_cert
      issuer_object = cert.issuer
      common_name = issuer_object.to_a.assoc('O')&.[](1)

      return {
        issuer_full: issuer_object.to_s,
        issuer_name: common_name,
        expiry_date: cert.not_after
      }
    end
  rescue => e
    Rails.logger.error("Erreur SSL pour #{name} : #{e.message}")
    nil
  end

  def get_domain_expiration
    result = { registrar: nil, expires_at: nil }
    whois = Whois::Client.new
    record = whois.lookup(name)
    parser = record.parser

    result[:expires_at] = parser.expires_on
    result[:registrar] = parser.registrar&.name

    raw_content = record.content

    if result[:expires_at].nil?
      if raw_content =~ /Registry Expiry Date:\s*([^\r\n]+)/i
        result[:expires_at] = Time.parse($1) rescue nil
      end
    end

    if result[:registrar].nil?
      if raw_content =~ /Registrar:\s*([^\r\n]+)/i
        result[:registrar] = $1.strip
      end
    end
    result

  rescue Whois::AttributeNotSupported
    Rails.logger.error("Le serveur Whois pour cette extension ne supporte pas l'extraction automatique de la date.")
    nil
  rescue StandardError => e
    Rails.logger.error("Erreur Whois pour #{name} : #{e.message}")
    nil
  end


  private

  def expiration_date_cannot_be_in_the_past
    if expires_at.present? && expires_at < Time.current
      errors.add(:expires_at, "doit être une date future")
    end
  end

  def self.as_json_api(relation)
    relation.map do |trust_asset|
      {
        name: trust_asset.name,
        issuer: trust_asset.issuer,
        format: trust_asset.format,
        expires_at: trust_asset.expires_at,
        consumer: trust_asset.consumer,
        description: trust_asset.description,
        reminder_days: trust_asset.reminder_days,
        environment: trust_asset.environment&.name
      }
    end
  end

  def index_to_meilisearch
    task = self.index! 
    MeiliSearch::Rails.client.wait_for_task(task.first.metadata["taskUid"])
  end

  meilisearch enqueue: false do
    add_attribute :id
    add_attribute :name
    add_attribute :expires_at
    add_attribute :issuer
    add_attribute :format
    add_attribute :consumer
    
    add_attribute :workspace_id do
      workspace&.id
    end
    add_attribute :environment_id do
      environment&.id
    end

    searchable_attributes [ :name, :expires_at, :issuer, :format, :consumer, :workspace_id, :environment_id ]

    filterable_attributes [ :name, :expires_at, :issuer, :format, :consumer, :workspace_id, :environment_id, :expires_at ]
  end  

  def self.cost
    self.count * Cost.find('TrustAsset').credits
  end
end
