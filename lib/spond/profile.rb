require_relative "resource"

module Spond
  class Profile < Resource
    attribute :first_name, key: "firstName"
    attribute :last_name, key: "lastName"
    attribute :primary_email, key: "primaryEmail"

    def self.get
      response = client.get("/profile")
      new(response)
    end

    def self.find_by_id(id)
      # This would be used for looking up profiles by ID
      # For now, return nil as we don't have a profiles endpoint
      nil
    end
  end
end
