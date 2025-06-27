require "spec_helper"

RSpec.describe Spond::Profile do
  let(:token) { "test-token-12345" }
  let(:client) { Spond::Client.new(token: token) }

  before do
    allow(Spond).to receive(:client).and_return(client)
  end

  describe ".get" do
    context "when the request is successful", :vcr do
      it "fetches and caches the profile data" do
        VCR.use_cassette("profile/get_success") do
          profile = described_class.get
          expect(profile).to be_a(Spond::Profile)
          expect(profile.id).to eq("user123")
          expect(profile.first_name).to eq("John")
          expect(profile.last_name).to eq("Doe")
          expect(profile.primary_email).to eq("john@example.com")
        end
      end
    end

    context "when the request fails", :vcr do
      it "raises an error" do
        VCR.use_cassette("profile/get_failure") do
          allow(client).to receive(:token).and_return("invalid-token")
          expect {
            described_class.get
          }.to raise_error(/API request failed/)
        end
      end
    end
  end

  describe "attributes" do
    let(:profile_data) do
      {
        "id" => "profile123",
        "firstName" => "John",
        "lastName" => "Doe",
        "primaryEmail" => "john@example.com",
        "email" => "john@secondary.com"
      }
    end

    let(:profile) { described_class.new(profile_data) }

    it "defines attribute readers using attribute method" do
      expect(profile.first_name).to eq("John")
      expect(profile.last_name).to eq("Doe")
      expect(profile.primary_email).to eq("john@example.com")
    end

    it "maps attribute keys correctly" do
      attributes = described_class.attributes
      expect(attributes).to include([:first_name, "firstName"])
      expect(attributes).to include([:last_name, "lastName"])
      expect(attributes).to include([:primary_email, "primaryEmail"])
    end

    it "inherits Resource base functionality" do
      expect(profile).to be_a(Spond::Resource)
      expect(profile.id).to eq("profile123")
      expect(profile.data).to eq(profile_data)
    end

    it "allows access to non-attribute data via method_missing" do
      expect(profile.email).to eq("john@secondary.com")
    end
  end
end
