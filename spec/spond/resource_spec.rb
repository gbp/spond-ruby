require "spec_helper"

RSpec.describe Spond::Resource do
  # Create a test class to test Resource functionality
  let(:test_class) do
    Class.new(Spond::Resource) do
      def self.name
        "TestResource"
      end

      attribute :name
      attribute :full_name, key: "fullName"
      attribute :age, key: "userAge"
      attribute :email
    end
  end

  let(:test_data) do
    {
      "id" => "123",
      "name" => "John",
      "fullName" => "John Doe",
      "userAge" => 30,
      "email" => "john@example.com",
      "extra_field" => "extra_value"
    }
  end

  let(:test_instance) { test_class.new(test_data) }

  describe ".attribute" do
    it "defines attr_reader for the attribute" do
      expect(test_instance).to respond_to(:name)
      expect(test_instance).to respond_to(:full_name)
      expect(test_instance).to respond_to(:age)
      expect(test_instance).to respond_to(:email)
    end

    it "stores attribute definitions" do
      attributes = test_class.attributes
      expect(attributes).to include([:name, "name"])
      expect(attributes).to include([:full_name, "fullName"])
      expect(attributes).to include([:age, "userAge"])
      expect(attributes).to include([:email, "email"])
    end

    it "uses the attribute name as key when no key specified" do
      attribute_def = test_class.attributes.find { |name, key| name == :name }
      expect(attribute_def).to eq([:name, "name"])
    end

    it "uses custom key when specified" do
      attribute_def = test_class.attributes.find { |name, key| name == :full_name }
      expect(attribute_def).to eq([:full_name, "fullName"])
    end
  end

  describe "#initialize" do
    it "sets attribute values from data" do
      expect(test_instance.name).to eq("John")
      expect(test_instance.full_name).to eq("John Doe")
      expect(test_instance.age).to eq(30)
      expect(test_instance.email).to eq("john@example.com")
    end

    it "sets id and data from parent Resource class" do
      expect(test_instance.id).to eq("123")
      expect(test_instance.data).to eq(test_data)
    end

    it "handles missing attributes gracefully" do
      incomplete_data = {"id" => "456", "name" => "Jane"}
      incomplete_instance = test_class.new(incomplete_data)

      expect(incomplete_instance.name).to eq("Jane")
      expect(incomplete_instance.full_name).to be_nil
      expect(incomplete_instance.age).to be_nil
      expect(incomplete_instance.email).to be_nil
    end
  end

  describe "inheritance" do
    it "creates separate attribute lists for subclasses" do
      subclass = Class.new(test_class) do
        attribute :phone
      end

      expect(test_class.attributes.map(&:first)).to contain_exactly(:name, :full_name, :age, :email)
      expect(subclass.attributes.map(&:first)).to contain_exactly(:phone)
    end

    it "does not share attributes between sibling classes" do
      sibling1 = Class.new(Spond::Resource) do
        attribute :field1
      end

      sibling2 = Class.new(Spond::Resource) do
        attribute :field2
      end

      expect(sibling1.attributes.map(&:first)).to eq([:field1])
      expect(sibling2.attributes.map(&:first)).to eq([:field2])
      expect(test_class.attributes.map(&:first)).to contain_exactly(:name, :full_name, :age, :email)
    end
  end

  describe "integration with method_missing" do
    it "prefers attribute methods over method_missing" do
      # name is defined as attribute, so it should use the attribute method
      expect(test_instance.name).to eq("John")

      # extra_field is not an attribute, so it should use method_missing
      expect(test_instance.extra_field).to eq("extra_value")
    end
  end

  describe "real world usage" do
    it "works with Profile-like class" do
      profile_class = Class.new(Spond::Resource) do
        def self.name
          "Profile"
        end

        attribute :first_name, key: "firstName"
        attribute :last_name, key: "lastName"
        attribute :primary_email, key: "primaryEmail"
      end

      profile_data = {
        "id" => "prof123",
        "firstName" => "Alice",
        "lastName" => "Johnson",
        "primaryEmail" => "alice@example.com"
      }

      profile = profile_class.new(profile_data)

      expect(profile.first_name).to eq("Alice")
      expect(profile.last_name).to eq("Johnson")
      expect(profile.primary_email).to eq("alice@example.com")
      expect(profile.id).to eq("prof123")
    end

    it "works with Comment-like class" do
      comment_class = Class.new(Spond::Resource) do
        def self.name
          "Comment"
        end

        attribute :from_profile_id, key: "fromProfileId"
        attribute :timestamp
        attribute :text
        attribute :children
        attribute :reactions

        def initialize(data)
          super
          @children ||= []
          @reactions ||= {}
        end
      end

      comment_data = {
        "id" => "comment123",
        "fromProfileId" => "prof456",
        "timestamp" => "2023-12-01T10:30:00Z",
        "text" => "Great comment!"
      }

      comment = comment_class.new(comment_data)

      expect(comment.from_profile_id).to eq("prof456")
      expect(comment.timestamp).to eq("2023-12-01T10:30:00Z")
      expect(comment.text).to eq("Great comment!")
      expect(comment.children).to eq([])  # Default from initialize
      expect(comment.reactions).to eq({}) # Default from initialize
    end
  end
end
