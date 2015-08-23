![Butterfli](http://cdn.delner.com/www/images/projects/butterfli/logo_small.svg)
Instagram (for Rails)
==========

[![Build Status](https://travis-ci.org/delner/butterfli-instagram-rails.svg?branch=master)](https://travis-ci.org/delner/butterfli-instagram-rails) ![Gem Version](https://badge.fury.io/rb/butterfli-instagram-rails.svg)
###### *For Ruby 1.9.3, 2.0.0, 2.1.0*

### Introduction

`butterfli-instagram-rails` adds Instagram API implementation to [Butterfli](https://github.com/delner/butterfli) for a Rails application, allowing it to receive data from Instagram. You can use this gem to receive subscription updates (photos, videos, etc) from Instagram in real-time.

This gem is a part of the Butterfli suite:

**Core gems**:
 - [`butterfli`](https://github.com/delner/butterfli): Core gem for Butterfli suite.
 - [`butterfli-rails`](https://github.com/delner/butterfli-rails): Core gem for Rails-engine based API interactions.

**Extension gems**:
 - [`butterfli-instagram`](https://github.com/delner/butterfli-instagram): Adds Instagram data to the Butterfli suite.
 - [`butterfli-instagram-rails`](https://github.com/delner/butterfli-instagram-rails): Adds Rails API endpoints for realtime-subscriptions.

### Installation

Add the gem to your `Gemfile` via `gem "butterfli-instagram-rails"`

Then configure Butterfli with your Instagram settings, by adding this to an initializer:

```ruby
Butterfli.configure do |config|
  config.provider :instagram do |provider|
    provider.client_id = "Your client ID"
    provider.client_secret = "Your client secret"
  end
end
```

And mount the engine within your `routes.rb` file:

```ruby
Rails.application.routes.draw do
  mount Butterfli::Instagram::Rails::Engine, at: "/butterfli"
end
```

### Usage

#### Receiving realtime subscription data from Instagram

In order to receive realtime data from Instagram, you must 'subscribe' by authenticating with their API. You can do this by running a rake task included within this gem.

First, start the Rails server: 
```bash
bundle exec rails server -b 0.0.0.0
```

Make sure its publicly accessible (most development servers are not), as Instagram will need to call your server to verify it. Check that your port is open, your IP is accessible from the internet, and the web server is listening on all addresses (the `-b 0.0.0.0` option sets this.)

Then setup the subscription with the rake task. The following is for [geography subscriptions](https://instagram.com/developer/realtime/):
```bash
# Arguments: [callback_url, latitude, longitute, radius (in meters)]
bundle exec rake butterfli:instagram:subscription:geography:setup['http://yourhost.com/butterfli/instagram/subscription/geography/callback',40.782956,-73.972106,5000]
```

If successful, Instagram will return a `200 OK` in the response. Your web server will now receive updates from Instagram until you unsubscribe. To do so, run the teardown rake task, which will remove all your subscriptions:
```ruby
bundle exec rake butterfli:instagram:subscription:teardown
```

In your application, you can access stories using `#subscribe` to register an event handler:
```ruby
Butterfli::Instagram.subscribe do |stories|
  puts "I received #{stories.length} stories!"
end
```

The above block will be called when any kind of story is received from Instagram. You can also subscribe to specific types of stories, using `to:` (NOTE: Currently, for Instagram, the only supported type is `:image`)
```ruby
Butterfli::Instagram.subscribe to: :image do |stories|
  puts "I received #{stories.length} image stories!"
end
```

### Changelog

#### Version 0.0.1

 - Initial version of `butterfli-instagram-rails` (extracted from `butterfli-rails`)
