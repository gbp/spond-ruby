require_relative "resource"

module Spond
  class Profile < Resource
    attr_reader :first_name, :last_name, :primary_email

    def self.get
      response = client.get("/profile")
      new(response)
    end

    def self.find_by_id(id)
      # This would be used for looking up profiles by ID
      # For now, return nil as we don't have a profiles endpoint
      nil
    end

    def initialize(data)
      super(data)
      @first_name = data["firstName"]
      @last_name = data["lastName"]
      @primary_email = data["primaryEmail"]
    end
  end
end
