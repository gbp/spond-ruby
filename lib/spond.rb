require_relative "spond/client"
require_relative "spond/version"

module Spond
  class Error < StandardError; end

  @client = nil

  def self.client
    @client ||= Client.new(
      email: ENV["SPOND_EMAIL"],
      password: ENV["SPOND_PASSWORD"],
      token: ENV["SPOND_TOKEN"]
    )
  end
end
