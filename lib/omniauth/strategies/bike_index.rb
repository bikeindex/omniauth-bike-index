require "omniauth-oauth2"

module OmniAuth
  module Strategies
    class BikeIndex < OmniAuth::Strategies::OAuth2
      option :name, :bike_index
      DEFAULT_SCOPE = "public"
      option :client_options, site: "https://bikeindex.org", authorize_url: "/oauth/authorize"

      uid { raw_info["id"] }

      info do
        prune!(
          "nickname"    => raw_info["user"]["username"],
          "bike_ids"    => raw_info["bike_ids"],
          "email"       => raw_info["user"]["email"],
          "name"        => raw_info["user"]["name"],
          "twitter"     => raw_info["user"]["twitter"],
          "image"       => raw_info["user"]["image"],
        )
      end

      extra do
        hash = {}
        hash["raw_info"] = raw_info unless skip_info?
        prune! hash
      end

      def raw_info
        @raw_info ||= access_token.get("/api/v3/me").parsed || {}
      end

      def request_phase
        options[:authorize_params] = { scope: (options["scope"] || DEFAULT_SCOPE), partner: options["partner"] }
        super
      end

      # https://github.com/omniauth/omniauth-oauth2/issues/81
      def callback_url
        full_host + script_name + callback_path
      end

      private

      def prune!(hash)
        hash.delete_if do |_, value|
          prune!(value) if value.is_a?(Hash)
          value.nil? || (value.respond_to?(:empty?) && value.empty?)
        end
      end
    end
  end
end