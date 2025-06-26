require "spec_helper"

RSpec.describe Spond::Event do
  let(:token) { "test-token-12345" }
  let(:client) { Spond::Client.new(token: token) }

  before do
    allow(Spond).to receive(:client).and_return(client)
  end

  describe ".where" do
    context "when the request is successful", :vcr do
      it "fetches the events data and returns Event instances" do
        VCR.use_cassette("event/where_success") do
          events = described_class.where
          expect(events).to be_a(Array)
          expect(events.first).to be_a(Spond::Event) if events.any?
        end
      end

      it "includes comments by default" do
        expect(client).to receive(:get).with("/sponds", params: {
          includeComments: true,
          addProfileInfo: true,
          order: 'asc'
        }).and_return([])
        described_class.where
      end

      it "accepts optional parameters and merges with defaults" do
        expect(client).to receive(:get).with("/sponds", params: {
          includeComments: true,
          addProfileInfo: true,
          order: 'asc',
          groupId: "123"
        }).and_return([])
        described_class.where(groupId: "123")
      end

      it "allows overriding defaults" do
        expect(client).to receive(:get).with("/sponds", params: {
          includeComments: false,
          addProfileInfo: true,
          order: 'asc'
        }).and_return([])
        described_class.where(includeComments: false)
      end
    end

    context "when the request fails", :vcr do
      it "raises an error" do
        VCR.use_cassette("event/where_failure") do
          allow(client).to receive(:token).and_return("invalid-token")
          expect {
            described_class.where
          }.to raise_error(/API request failed/)
        end
      end
    end
  end

  describe ".for_group" do
    it "calls .where with groupId parameter" do
      expect(described_class).to receive(:where).with(groupId: "group-123")
      described_class.for_group("group-123")
    end

    it "allows overriding parameters" do
      expect(described_class).to receive(:where).with(
        groupId: "group-123",
        includeComments: false
      )
      described_class.for_group("group-123", includeComments: false)
    end
  end

  describe "instance methods" do
    let(:event_data) do
      {
        "id" => "event123",
        "title" => "Test Event",
        "comments" => [
          {
            "id" => "comment1",
            "text" => "Great event!",
            "fromProfileId" => "profile1",
            "timestamp" => "2023-12-01T10:30:00Z",
            "children" => [],
            "reactions" => {}
          }
        ]
      }
    end
    let(:event) { described_class.new(event_data) }

    describe "Resource base functionality" do
      it "inherits common Resource functionality" do
        expect(event).to be_a(Spond::Resource)
        expect(event.id).to eq("event123")
        expect(event.data).to eq(event_data)
      end

      it "provides data access via method_missing" do
        expect(event.title).to eq("Test Event")
      end

      it "raises NoMethodError for keys that don't exist" do
        expect { event.nonexistent_field }.to raise_error(NoMethodError)
      end

      it "responds correctly to attribute queries" do
        expect(event.respond_to?(:title)).to be true
        expect(event.respond_to?(:nonexistent_field)).to be false
      end
    end

    describe "#comments (has_many association)" do
      it "loads comments via has_many local association" do
        expect(event.comments).to be_an(Array)
        expect(event.comments.length).to eq(1)
        expect(event.comments.first).to be_a(Spond::Comment)
        expect(event.comments.first.id).to eq("comment1")
      end

      it "handles events without comments" do
        event_without_comments = described_class.new({"id" => "event456"})
        expect(event_without_comments.comments).to eq([])
      end

      it "memoizes comments" do
        # Access comments twice to ensure memoization
        first_access = event.comments
        second_access = event.comments
        expect(first_access).to equal(second_access)
      end
    end

    describe "#has_comments?" do
      it "returns true when comments exist" do
        expect(event.has_comments?).to be true
      end

      it "returns false when no comments exist" do
        event_without_comments = described_class.new({"id" => "event456"})
        expect(event_without_comments.has_comments?).to be false
      end
    end

    describe "#comment_count" do
      it "returns the number of comments" do
        expect(event.comment_count).to eq(1)
      end
    end


  end
end
