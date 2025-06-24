require_relative "resource"

module Spond
  class Event < Resource
    def self.where
      client.get("/sponds")
    end
  end
end
