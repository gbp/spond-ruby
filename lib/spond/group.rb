require_relative "resource"

module Spond
  class Group < Resource
    has_many :events, "Event", scope_method: :for_group

    def self.all
      response = client.get("/groups")
      response.map { |group_data| new(group_data) }
    end
  end
end
