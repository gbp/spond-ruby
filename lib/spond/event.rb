require_relative "resource"

module Spond
  class Event < Resource
    has_many :comments, "Comment", local: true

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

    def has_comments?
      comments.any?
    end

    def comment_count
      comments.size
    end
  end
end
