RSpec.describe Spond::Client do
  let(:email) { "test@example.com" }
  let(:password) { "password123" }
  let(:token) { "test-token" }
  let(:client) { described_class.new(email: email, password: password) }

  describe "#request" do
    let(:client_with_token) { described_class.new(token: token) }

    it "includes User-Agent header with gem version" do
      URI("#{described_class::API_URL}/profile")
      http_client = instance_double(Net::HTTP)
      allow(Net::HTTP).to receive(:new).and_return(http_client)
      allow(http_client).to receive(:use_ssl=)

      expect(http_client).to receive(:request) do |request|
        expect(request["User-Agent"]).to eq("spond-ruby/#{Spond::VERSION}")
        double(code: "200", body: "[]")
      end

      client_with_token.get("/profile")
    end
  end

  describe "#initialize" do
    context "with email and password" do
      it "authenticates automatically", :vcr do
        VCR.use_cassette("authentication_success") do
          client = described_class.new(email: email, password: password)
          expect(client.token).not_to be_nil
        end
      end

      it "handles authentication failure", :vcr do
        VCR.use_cassette("authentication_failure") do
          expect {
            described_class.new(email: "wrong@email.com", password: "wrongpass")
          }.to raise_error(/API request failed/)
        end
      end
    end

    context "with token" do
      it "skips authentication" do
        client = described_class.new(token: token)
        expect(client.token).to eq(token)
      end
    end
  end

  describe "error handling" do
    let(:client_with_token) { described_class.new(token: token) }

    it "raises error for invalid HTTP method" do
      expect {
        client_with_token.send(:request, "INVALID", "/endpoint")
      }.to raise_error(/Unsupported HTTP method/)
    end

    it "handles network errors", :vcr do
      VCR.use_cassette("network_error") do
        allow_any_instance_of(Net::HTTP).to receive(:request).and_raise(Errno::ECONNREFUSED)
        expect {
          client_with_token.get("/profile")
        }.to raise_error(Errno::ECONNREFUSED)
      end
    end

    it "handles malformed JSON responses", :vcr do
      VCR.use_cassette("malformed_json") do
        expect {
          client_with_token.get("/profile")
        }.to raise_error(JSON::ParserError)
      end
    end
  end
end
