# OmniAuth::BikeIndex [![Build Status](https://travis-ci.org/bikeindex/omniauth-bike-index.svg?branch=master)](https://travis-ci.org/bikeindex/omniauth-bike-index)

Bike Index OAuth2 Strategy for OmniAuth 1.0.

Supports the OAuth 2.0 server-side and client-side flows.

## Creating an application

To be able to use OAuth on the Bike Index, you have to create an application. Go to [BikeIndex.org/oauth/applications](https://bikeindex.org/oauth/applications) to add your application.

Once you've added your application and your routes, you'll be able to see your Application ID and Secret, which you will need for omniauth.

**Note**: Callback url has to be an exact match - if your url is `http://localhost:3001/users/auth/bike_index/callback` you _must_ enter that exactly - `http://localhost:3001/users/auth/` will not work.

Check out the **[Bike Index API Documentation](https://bikeindex.org/documentation)** to see what can be done with authenticated users.

## Usage

First add it to you Gemfile:

`gem 'omniauth-bike-index'`

Here's a quick example, adding the middleware to a Rails app in
`config/initializers/omniauth.rb`:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :bike_index, ENV['BIKEINDEX_APP_ID'], ENV['BIKEINDEX_APP_SECRET']
end
```

Your `BIKEINDEX_APP_ID` and your `BIKEINDEX_APP_SECRET` are both application specific. To create or view your applications go to [BikeIndex.org/oauth/applications](https://bikeindex.org/oauth/applications).

Edit your routes.rb file to have:

`devise_for :users, controllers: { omniauth_callbacks: 'omniauth_callbacks' }`

And create a file called `omniauth_callbacks_controller.rb` which should have this inside:

```ruby
class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def bike_index
    # Delete the code inside of this method and write your own.
    # The code below is to show you where to access the data.
    raise request.env['omniauth.auth'].to_json
  end
end
```

## Scopes

The default scope is `public` - which will be submitted unless you configure additional scopes. You can set scopes in the configuration with a space seperated list, e.g. for Devise

```ruby
Devise.setup do |config|
  config.omniauth :bike_index, ENV['BIKEINDEX_APP_ID'], ENV['BIKEINDEX_APP_SECRET'], scope: 'read_bikes write_user read_user`
end
```

Available scopes: `read_user`, `write_user`, `read_bikes`, `write_bikes`

## Credentials

If you don't include a scope, the response will include a `uid` from Bike Index for the user and nothing else.

If you include the `read_bikes` scope, the response will include an array of the ids the user has registered on the Index `bike_ids: [3414, 29367]`

You can use these IDs to access information about the bikes - e.g. [api/v3/bikes/3414](https://bikeindex.org/api/v3/bikes/3414) & [api/v3/bikes/29367](https://bikeindex.org/api/v3/bikes/29367)

If you include the `read_user` scope, the response will include the user's nickname, email and name. You will also see their twitter handle and avatar if they have added them. The keys for these items -
`nickname`, `email`, `name`, `twitter` & `image` - all accessible in the `request.env['omniauth.auth']`, e.g. `request.env['omniauth.auth'].info.email`

## Auth Hash

You can also see the authetication hash (in JSON format) by going to the authentication url on the Bike Index with the user's access token - `https://bikeindex.org/api/v3/me?access_token=<OAUTH_ACCESS_TOKEN>`
