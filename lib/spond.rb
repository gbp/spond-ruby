require_relative "spond/client"
require_relative "spond/event"
require_relative "spond/profile"
require_relative "spond/group"
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

  def self.profile
    @profile ||= Profile.get
  end

  def self.groups
    @groups ||= Group.all
  end

  def self.events(**args)
    Event.where(**args)
  end
end
