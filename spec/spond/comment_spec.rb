require "spec_helper"

RSpec.describe Spond::Comment do
  let(:comment_data) do
    {
      "id" => "comment123",
      "fromProfileId" => "profile123",
      "timestamp" => "2023-12-01T10:30:00Z",
      "text" => "This is my witty comment",
      "children" => [
        {
          "id" => "child_comment456",
          "fromProfileId" => "profile456",
          "timestamp" => "2023-12-01T10:35:00Z",
          "text" => "This is a reply",
          "children" => [],
          "reactions" => {}
        }
      ],
      "reactions" => {
        "👍" => {"profile123" => 0, "profile789" => 0},
        "❤️" => {"profile456" => 0}
      }
    }
  end

  let(:comment) { described_class.new(comment_data) }

  describe "attribute functionality" do
    it "defines attribute readers using attribute method" do
      expect(comment.from_profile_id).to eq("profile123")
      expect(comment.timestamp).to eq("2023-12-01T10:30:00Z")
      expect(comment.text).to eq("This is my witty comment")
      expect(comment.children).to be_an(Array)
      expect(comment.reactions).to be_a(Hash)
    end

    it "maps attribute keys correctly" do
      attributes = described_class.attributes
      expect(attributes).to include([:from_profile_id, "fromProfileId"])
      expect(attributes).to include([:timestamp, "timestamp"])
      expect(attributes).to include([:text, "text"])
      expect(attributes).to include([:children, "children"])
      expect(attributes).to include([:reactions, "reactions"])
    end

    it "inherits Resource base functionality" do
      expect(comment).to be_a(Spond::Resource)
      expect(comment.id).to eq("comment123")
      expect(comment.data).to eq(comment_data)
    end

    it "sets default values in initialize" do
      comment_without_children = described_class.new({"id" => "test", "text" => "test"})
      expect(comment_without_children.children).to eq([])
      expect(comment_without_children.reactions).to eq({})
    end

    it "allows access to non-attribute data via method_missing" do
      expect(comment.fromProfileId).to eq("profile123")
    end

    it "raises NoMethodError for keys that don't exist" do
      expect { comment.nonexistent_field }.to raise_error(NoMethodError)
    end

    it "responds correctly to attribute and method_missing queries" do
      expect(comment.respond_to?(:text)).to be true  # attribute
      expect(comment.respond_to?(:fromProfileId)).to be true  # method_missing
      expect(comment.respond_to?(:nonexistent_field)).to be false
    end
  end

  describe "#timestamp_parsed" do
    it "parses timestamp into Time object" do
      expect(comment.timestamp_parsed).to be_a(Time)
      expect(comment.timestamp_parsed.year).to eq(2023)
      expect(comment.timestamp_parsed.month).to eq(12)
      expect(comment.timestamp_parsed.day).to eq(1)
    end

    it "returns nil for missing timestamp" do
      no_timestamp_comment = described_class.new({"id" => "test"})
      expect(no_timestamp_comment.timestamp_parsed).to be_nil
    end

    it "memoizes the parsed timestamp" do
      expect(Time).to receive(:parse).once.and_call_original
      comment.timestamp_parsed
      comment.timestamp_parsed
    end
  end

  describe "#has_reactions?" do
    it "returns true when reactions exist" do
      expect(comment.has_reactions?).to be true
    end

    it "returns false when no reactions exist" do
      no_reactions_comment = described_class.new({"id" => "test", "reactions" => {}})
      expect(no_reactions_comment.has_reactions?).to be false
    end
  end

  describe "#reaction_count" do
    it "returns total reaction count when no emoji specified" do
      expect(comment.reaction_count).to eq(3) # 2 thumbs up + 1 heart
    end

    it "returns count for specific emoji" do
      expect(comment.reaction_count("👍")).to eq(2)
      expect(comment.reaction_count("❤️")).to eq(1)
      expect(comment.reaction_count("😂")).to eq(0)
    end
  end

  describe "#reaction_emojis" do
    it "returns array of reaction emoji keys" do
      expect(comment.reaction_emojis).to contain_exactly("👍", "❤️")
    end
  end

  describe "#has_children?" do
    it "returns true when children exist" do
      expect(comment.has_children?).to be true
    end

    it "returns false when no children exist" do
      no_children_comment = described_class.new({"id" => "test", "children" => []})
      expect(no_children_comment.has_children?).to be false
    end
  end

  describe "#child_comments" do
    it "returns array of Comment objects" do
      child_comments = comment.child_comments
      expect(child_comments).to be_an(Array)
      expect(child_comments.length).to eq(1)
      expect(child_comments.first).to be_a(described_class)
      expect(child_comments.first.id).to eq("child_comment456")
    end

    it "memoizes the child comments" do
      comment # load comment which calls #new before stub it below
      expect(described_class).to receive(:new).once.and_call_original
      comment.child_comments
      comment.child_comments
    end
  end
end
