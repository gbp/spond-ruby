require_relative "resource"

module Spond
  class Event < Resource
    attr_reader :id, :data, :comments

    def self.where(params = {})
      params = {
        includeComments: true,
        addProfileInfo: true,
        order: 'asc'
      }.merge(params)
      response = client.get("/sponds", params: params)
      response.map { |event_data| new(event_data) }
    end

    def self.for_group(group_id, params = {})
      where(**params.merge(groupId: group_id))
    end

    def initialize(data)
      @data = data
      @id = data["id"]
      @comments = parse_comments(data["comments"] || [])
    end

    def has_comments?
      @comments.any?
    end

    def comment_count
      @comments.size
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

    private

    def parse_comments(comments_data)
      comments_data.map { |comment_data| Comment.new(comment_data) }
    end
  end
end
