require_relative "resource"

module Spond
  class Group < Resource
    def self.all
      client.get("/groups")
    end
  end
end
