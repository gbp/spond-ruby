require_relative "resource"

module Spond
  class Event < Resource
    def self.where(params = {})
      client.get("/sponds", params: params)
    end

    def self.for_group(group_id)
      where(groupId: group_id)
    end
  end
end
