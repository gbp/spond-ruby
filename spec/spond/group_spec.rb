require "spec_helper"

RSpec.describe Spond::Group do
  let(:token) { "test-token-12345" }
  let(:client) { Spond::Client.new(token: token) }

  before do
    allow(Spond).to receive(:client).and_return(client)
  end

  describe ".all" do
    context "when the request is successful", :vcr do
      it "fetches the groups data and returns Group instances" do
        VCR.use_cassette("group/all_success") do
          groups = described_class.all
          expect(groups).to be_a(Array)
          expect(groups.first).to be_a(Spond::Group) if groups.any?
        end
      end
    end

    context "when the request fails", :vcr do
      it "raises an error" do
        VCR.use_cassette("group/all_failure") do
          allow(client).to receive(:token).and_return("invalid-token")
          expect {
            described_class.all
          }.to raise_error(/API request failed/)
        end
      end
    end
  end

  describe "instance methods" do
    let(:group_data) { {"id" => "123", "name" => "Test Group", "description" => "A test group"} }
    let(:group) { described_class.new(group_data) }

    describe "Resource base functionality" do
      it "inherits common Resource functionality" do
        expect(group).to be_a(Spond::Resource)
        expect(group.id).to eq("123")
        expect(group.data).to eq(group_data)
      end

      it "provides data access via method_missing" do
        expect(group.name).to eq("Test Group")
        expect(group.description).to eq("A test group")
      end

      it "raises NoMethodError for keys that don't exist" do
        expect { group.nonexistent_field }.to raise_error(NoMethodError)
      end

      it "responds correctly to attribute queries" do
        expect(group.respond_to?(:name)).to be true
        expect(group.respond_to?(:description)).to be true
        expect(group.respond_to?(:nonexistent_field)).to be false
      end
    end

    describe "#events (has_many association)" do
      it "calls Event.for_group with the group id via has_many" do
        expect(Spond::Event).to receive(:for_group).with("123").and_return([])
        group.events
      end

      it "memoizes the result" do
        expect(Spond::Event).to receive(:for_group).with("123").and_return([]).once
        group.events
        group.events
      end
    end
  end
end
