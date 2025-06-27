module Spond
  class Resource
    attr_reader :id, :data

    # Class variable to store defined attributes
    @attributes = []

    def self.attributes
      @attributes ||= []
    end

    def self.attribute(name, key: nil)
      key ||= name.to_s
      attributes << [name, key]
      attr_reader name
    end

    def self.inherited(subclass)
      super
      subclass.instance_variable_set(:@attributes, [])
    end

    def self.client
      Spond.client
    end

    # Helper method for creating scoped associations
    def self.has_many(association_name, class_name, scope_param: nil, scope_method: nil, local: false)
      define_method(association_name) do
        association_class = Object.const_get("Spond::#{class_name}")
        instance_var = "@#{association_name}"

        return instance_variable_get(instance_var) if instance_variable_defined?(instance_var)

        result = if local
          # For local associations, parse embedded data
          embedded_data = @data[association_name.to_s] || []
          embedded_data.map { |item_data| association_class.new(item_data) }
        elsif scope_method
          association_class.send(scope_method, @id)
        elsif scope_param
          association_class.all(scope_param => @id)
        else
          association_class.all
        end

        instance_variable_set(instance_var, result)
      end
    end

    def initialize(data)
      @data = data
      @id = data["id"]

      # Set attribute values from data
      self.class.attributes.each do |name, key|
        instance_variable_set("@#{name}", @data[key])
      end
    end

    def method_missing(method_name, *args, &block)
      if @data.key?(method_name.to_s)
        @data[method_name.to_s]
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      @data.key?(method_name.to_s) || super
    end
  end
end
