class Plan
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :id, :string
  attribute :price, :decimal, precision: 10, scale: 2
  attribute :price_annual, :decimal, precision: 10, scale: 2
  attribute :next_plan, :string
  attribute :available, :boolean
  attribute :credits, :integer
  attribute :price_package, :decimal, precision: 10, scale: 2
  attribute :active, :boolean
  attribute :branding_custom, :boolean
  attribute :description, :string
  attribute :order, :integer

  DATA_PATH = Rails.root.join("config", "plan_data.yml")

  def name
    I18n.t("member.pricings.index.plans.#{id}.name")
  end

  def description
    I18n.t("member.pricings.index.plans.#{id}.description")
  end  

  def self.client
    @client ||= Stripe::StripeClient.new(Stripe.api_key)
  end

  def full_name
    "KH - #{self.name}"
  end

  def self.products
    return @products if @products
    @products = client.v1.products.list.data
    @products
  end

  def product_exists_in_stripe?
    Plan.products.each do |product|
      return product["id"] if product["name"] == self.full_name
    end
    product = Plan.client.v1.products.create({ name: full_name })
    @products = nil
    product["id"]
  end

  def price_id!(period)
    product_id = product_exists_in_stripe?
    price_id?("#{self.name} - #{period.capitalize}")
  end

  def meter_exists_in_stripe?
    meters = Plan.client.v1.billing.meters.list.data
    meters.each do |meter|      
      return meter["id"] if meter["event_name"] == 'credit'
    end
    meter = Plan.client.v1.billing.meters.create({
      display_name: 'Crédits',
      event_name: 'credit',
      default_aggregation: { formula: 'sum' },
      value_settings: { event_payload_key: 'value' },
      customer_mapping: {
        type: 'by_id',
        event_payload_key: 'stripe_customer_id'
      }
    })
    meter['id']
  end

  def price_id?(nickname)
    Plan.client.v1.prices.list.each do |price|
      return price["id"] if price["nickname"] == nickname
    end
    nil
  end

  def create_price(product_id, meter_id, interval, price)
    return if price_id?("#{self.name} - #{interval.capitalize}")

    puts "Creating price for product #{product_id} with interval #{interval} and amount #{price}..."
    price = Plan.client.v1.prices.create({
      currency: 'cad',
      unit_amount: price,
      billing_scheme: "per_unit",
      tax_behavior: 'exclusive',
      recurring: {
        interval: interval,
        interval_count: 1,
        usage_type: 'licensed'
      },
      product: product_id,
      nickname: "#{self.name} - #{interval.capitalize}"
    })
  end

  def prices(product_id)
    return if self.price == 0

    puts "Updating prices for product #{product_id}..."
    # meter_id = meter_exists_in_stripe?
    meter_id = nil
    create_price(product_id, meter_id, 'month', (self.price * 100).to_i)
    create_price(product_id, meter_id, 'year', (self.price_annual * 100).to_i)
  end
  
  def sync_with_stripe
    product_id = product_exists_in_stripe?
    puts "Updating prices for product #{product_id}...".light_blue
    prices(product_id) #
  end
  
  def self.all
    @all ||= begin
      yaml_data = YAML.load_file(DATA_PATH)
      yaml_data.map { |attributes| new(attributes) }
    end
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
