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

    def self.before(time, params = {})
      where(**params.merge(maxEndTimestamp: time))
    end

    def self.past(params = {})
      before(Time.now, params)
    end

    def self.after(time, params = {})
      where(**params.merge(minStartTimestamp: time))
    end

    def self.future(params = {})
      after(Time.now, params)
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
