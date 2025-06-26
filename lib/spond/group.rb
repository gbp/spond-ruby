require_relative "resource"

module Spond
  class Group < Resource
    attr_reader :id, :data

    has_many :events, "Event", scope_method: :for_group

    def self.all
      response = client.get("/groups")
      response.map { |group_data| new(group_data) }
    end

    def initialize(data)
      @data = data
      @id = data["id"]
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
