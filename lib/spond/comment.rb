require_relative "resource"

module Spond
  class Comment < Resource
    attr_reader :from_profile_id, :timestamp, :text, :children, :reactions

    def initialize(data)
      super(data)
      @from_profile_id = data["fromProfileId"]
      @timestamp = data["timestamp"]
      @text = data["text"]
      @children = data["children"] || []
      @reactions = data["reactions"] || {}
    end

    def timestamp_parsed
      @timestamp_parsed ||= Time.parse(@timestamp) if @timestamp
    end

    def has_reactions?
      @reactions.any?
    end

    def reaction_count(emoji = nil)
      return @reactions.values.sum { |profiles| profiles.size } unless emoji
      @reactions[emoji]&.size || 0
    end

    def reaction_emojis
      @reactions.keys
    end

    def has_children?
      @children.any?
    end

    def child_comments
      @child_comments ||= @children.map { |child_data| self.class.new(child_data) }
    end
  end
end
