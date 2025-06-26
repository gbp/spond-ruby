module Spond
  class Resource
    def self.client
      Spond.client
    end

    # Helper method for creating scoped associations
    def self.has_many(association_name, class_name, scope_param: nil, scope_method: nil)
      define_method(association_name) do
        association_class = Object.const_get("Spond::#{class_name}")
        instance_var = "@#{association_name}"

        return instance_variable_get(instance_var) if instance_variable_defined?(instance_var)

        result = if scope_method
          association_class.send(scope_method, @id)
        elsif scope_param
          association_class.all(scope_param => @id)
        else
          association_class.all
        end

        instance_variable_set(instance_var, result)
      end
    end
  end
end
