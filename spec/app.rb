$LOAD_PATH.unshift File.expand_path("..", __FILE__)
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "dotenv"
require "sinatra"
require "omniauth"
require "omniauth-bike-index"

Dotenv.load

use Rack::Session::Cookie, key: "key",
                           domain: "localhost",
                           path: "/",
                           expire_after: 14_400,
                           secret: "secret"

use OmniAuth::Builder do
  provider :bike_index, ENV["CLIENT_ID"], ENV["CLIENT_SECRET"], scope: "access_profile"
end

get "/" do
  <<-HTML
  <a href='/auth/bikeindex'>Sign in with Bike Index</a>
  HTML
end

get "/auth/failure" do
  env["omniauth.error"].to_s
end

get "/auth/:name/callback" do
  auth = request.env["omniauth.auth"]

  puts %(
    >> UID
      #{auth.uid.inspect}

    >> ACCESS TOKEN
      #{auth.credentials.token.inspect}

    >> INFO
      #{auth.info.inspect}
      #
    >> EXTRA
      #{auth.extra.inspect}
  )

  "Check logs for user information."
end
