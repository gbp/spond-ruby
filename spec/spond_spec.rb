RSpec.describe Spond do
  describe ".client" do
    before do
      # Clear any existing client instance
      Spond.instance_variable_set(:@client, nil)

      # Store original ENV values
      @original_env = {
        "SPOND_EMAIL" => ENV["SPOND_EMAIL"],
        "SPOND_PASSWORD" => ENV["SPOND_PASSWORD"],
        "SPOND_TOKEN" => ENV["SPOND_TOKEN"]
      }
    end

    after do
      # Restore original ENV values
      @original_env.each do |key, value|
        ENV[key] = value
      end
    end

    context "when environment variables are set" do
      before do
        ENV["SPOND_EMAIL"] = "test@example.com"
        ENV["SPOND_PASSWORD"] = "password123"
        ENV["SPOND_TOKEN"] = "test-token"
      end

      it "returns a Client instance" do
        expect(Spond.client).to be_a(Spond::Client)
      end

      it "memoizes the client instance" do
        first_client = Spond.client
        second_client = Spond.client
        expect(first_client).to eq(second_client)
      end

      it "initializes client with correct credentials" do
        client = Spond.client
        expect(client.instance_variable_get(:@email)).to eq("test@example.com")
        expect(client.instance_variable_get(:@password)).to eq("password123")
        expect(client.instance_variable_get(:@token)).to eq("test-token")
      end
    end

    context "when environment variables are not set" do
      before do
        ENV["SPOND_EMAIL"] = nil
        ENV["SPOND_PASSWORD"] = nil
        ENV["SPOND_TOKEN"] = nil
      end

      it "initializes client with nil values" do
        client = Spond.client
        expect(client.instance_variable_get(:@email)).to be_nil
        expect(client.instance_variable_get(:@password)).to be_nil
        expect(client.instance_variable_get(:@token)).to be_nil
      end
    end
  end

  describe ".profile" do
    it "calls Profile.get" do
      expect(Spond::Profile).to receive(:get)
      Spond.profile
    end

    it "memorizes the result" do
      expect(Spond::Profile).to receive(:get).and_return(double).once
      Spond.profile
      Spond.profile
    end
  end

  it "has a version number" do
    expect(Spond::VERSION).not_to be_nil
  end
end
