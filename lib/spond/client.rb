require "json"
require "net/http"
require "uri"

module Spond
  class Client
    API_URL = "https://api.spond.com/core/v1"
    AUTH_PATH = "/auth2/login"

    attr_reader :token

    def initialize(email: nil, password: nil, token: nil)
      @email = email
      @password = password
      @token = token

      authenticate if @email && @password && !@token
    end

    def get(endpoint, params: nil)
      request("GET", endpoint, params: params)
    end

    def post(endpoint, data: nil)
      request("POST", endpoint, data: data)
    end

    def put(endpoint, data: nil)
      request("PUT", endpoint, data: data)
    end

    def delete(endpoint)
      request("DELETE", endpoint)
    end

    private

    def authenticate
      data = {email: @email, password: @password}
      @token = post(AUTH_PATH, data: data)["accessToken"]["token"]
    end

    def request(method, endpoint, data: nil, params: nil)
      uri = URI("#{API_URL}#{endpoint}")
      uri.query = URI.encode_www_form(params) if params

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request_class = case method.downcase
      when "get" then Net::HTTP::Get
      when "post" then Net::HTTP::Post
      when "put" then Net::HTTP::Put
      when "delete" then Net::HTTP::Delete
      else
        raise "Unsupported HTTP method: #{method}"
      end

      request = request_class.new(uri)
      request["Content-Type"] = "application/json"
      request["Authorization"] = "Bearer #{@token}" if @token
      request.body = data.to_json if data

      response = http.request(request)

      return JSON.parse(response.body) if response.code == "200"

      raise "API request failed: #{response.body}"
    end
  end
end
