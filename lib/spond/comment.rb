require_relative "resource"

module Spond
  class Comment < Resource
    attribute :from_profile_id, key: "fromProfileId"
    attribute :timestamp
    attribute :text
    attribute :children, default: []
    attribute :reactions, default: {}

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
