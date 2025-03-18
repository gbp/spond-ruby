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
          profile_data = described_class.get
          expect(profile_data).to include(
            "id" => "user123",
            "firstName" => "John",
            "lastName" => "Doe",
            "primaryEmail" => "john@example.com"
          )
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
end
