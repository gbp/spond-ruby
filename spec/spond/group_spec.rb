require "spec_helper"

RSpec.describe Spond::Group do
  let(:token) { "test-token-12345" }
  let(:client) { Spond::Client.new(token: token) }

  before do
    allow(Spond).to receive(:client).and_return(client)
  end

  describe ".all" do
    context "when the request is successful", :vcr do
      it "fetches the groups data" do
        VCR.use_cassette("group/all_success") do
          groups_data = described_class.all
          expect(groups_data).to be_a(Array)
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
end
