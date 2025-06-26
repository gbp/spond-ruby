require "spec_helper"

RSpec.describe Spond::Event do
  let(:token) { "test-token-12345" }
  let(:client) { Spond::Client.new(token: token) }

  before do
    allow(Spond).to receive(:client).and_return(client)
  end

  describe ".where" do
    context "when the request is successful", :vcr do
      it "fetches the events data" do
        VCR.use_cassette("event/where_success") do
          events_data = described_class.where
          expect(events_data).to be_a(Array)
        end
      end

      it "accepts optional parameters" do
        expect(client).to receive(:get).with("/sponds", params: {groupId: "123"})
        described_class.where(groupId: "123")
      end

      it "calls client.get with no params when no arguments given" do
        expect(client).to receive(:get).with("/sponds", params: {})
        described_class.where
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
  end
end
