require 'rest_client'

module Connfu
  module Provisioning

    ##
    # This class is the responsible of any HTTP request to connFu endpoint
    #
    class Base

      # valid api_key that authenticates the application
      attr_accessor :api_key

      # Connfu endpoint (host:port)
      attr_accessor :endpoint

      ##
      # Initializer
      # ==== Parameters
      # * +api_key+ valid api_key that authenticates the application
      # * +endpoint+ Connfu endpoint (host:port)
      #
      def initialize(api_key, endpoint = nil)
        @api_key = api_key
        @endpoint = endpoint.nil? ? Base.endpoint : endpoint # if no endpoint retrieved, try to use the class one
      end

      ##
      # HTTP GET request
      #
      def get(path, params = {}, headers = {})
        headers.merge!(base_headers).merge!({:Accept => "application/json"})
        RestClient.get("#{@endpoint}/#{path}?".concat(params.collect { |k, v| "#{k}=#{v.to_s}" }.join("&")), headers)
      end

      ##
      # HTTP POST request
      #
      def post(path, body = {}, headers = {})
        headers.merge!(base_headers).merge!({:content_type => :json, :Accept => "application/json"})
        RestClient.post("#{@endpoint}/#{path}", ActiveSupport::JSON.encode(body), headers) { |response, request, result|
          case response.code
            when 200..201
              # If there is a :location header, return it
              if response.headers.has_key?(:location)
                return response.headers[:location]
              end
              # else, do the normal stuff
              if block_given?
                response.return!(request, result, &Proc.new)
              else
                response.return!(request, result)
              end
            else
              if block_given?
                response.return!(request, result, &Proc.new)
              else
                response.return!(request, result)
              end
          end
        }
      end

      ##
      # HTTP PUT request
      #
      def put(path, body = {}, headers = {})
        headers.merge!(base_headers).merge!({:content_type => :json, :Accept => "application/json"})
        RestClient.put("#{@endpoint}/#{path}", ActiveSupport::JSON.encode(body), headers)
      end

      ##
      # HTTP DELETE request
      #
      def delete(path, params = {}, headers = {})
        headers.merge!(base_headers).merge!({:content_type => :json, :Accept => "application/json"})
        RestClient.delete("#{@endpoint}/#{path}?".concat(params.collect { |k, v| "#{k}=#{v.to_s}" }.join("&")), headers)
      end

      class << self
        # Enable to configure just once the endpoint
        attr_accessor :endpoint
      end

      private

      ##
      # Required HTTP headers to be sent in each request
      def base_headers
        {:AUTH_TOKEN => "#{@api_key}", :REQUEST_ID => "#{@api_key[0..10]}#{Time.now.to_i.to_s}"}
      end

    end
  end
end
