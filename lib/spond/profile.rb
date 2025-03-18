require_relative "resource"

module Spond
  class Profile < Resource
    def self.get
      client.get("/profile")
    end
  end
end
