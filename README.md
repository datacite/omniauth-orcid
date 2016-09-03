# OmniAuth ORCID

[![Gem Version](https://badge.fury.io/rb/omniauth-orcid.svg)](https://badge.fury.io/rb/omniauth-orcid)
[![Build Status](https://travis-ci.org/datacite/omniauth-orcid.svg?branch=master)](https://travis-ci.org/datacite/omniauth-orcid)
[![DOI](https://zenodo.org/badge/15088/datacite/omniauth-orcid.svg)](https://zenodo.org/badge/latestdoi/15088/datacite/omniauth-orcid)

ORCID OAuth 2.0 Strategy for the [OmniAuth Ruby authentication framework](http://www.omniauth.org).

Provides basic support for connecting a client application to the [Open Researcher & Contributor ID registry service](http://orcid.org).

Originally created for the [ORCID example client application in Rails](https://github.com/gthorisson/ORCID-example-client-app-rails), then turned into a gem.

This gem is used in the [DataCite-ORCID claiming tool](https://github.com/datacite/DataCite-ORCID) and the [Lagotto](https://github.com/lagotto/lagotto) open source application for tracking events around articles and other scholarly outputs.

[GrowKudos](https://www.growkudos.com) is a web app where the gem is in active use. There's a free registration during which (and after which) an ORCID can be connected via oAuth.


## Installation

The usual way with Bundler: add the following to your `Gemfile` to install the current version of the gem:

```ruby
gem 'omniauth-orcid'
```

Then run `bundle install` to install into your environment.

You can also install the gem system-wide in the usual way:

```bash
gem install omniauth-orcid
```


## Getting started

Like other OmniAuth strategies, `OmniAuth::Strategies::ORCID` is a piece of Rack middleware. Please read the OmniAuth documentation for detailed instructions: https://github.com/intridea/omniauth.

There are three ways to register a client application and obtain client app credentials (`client_id` and `client_secret`) as well as a `site URL`:

* for non-members (the default): Register your client application in the `Developer Tools` section of your ORCID profile.
* for members (production): Register your client application [here](http://orcid.org/content/register-client-application).
* for development (sandbox): Register your client application [here](https://orcid.org/content/register-client-application-sandbox).

By default the module connects to the live ORCID service for non-members. All you have to provide are your client app credentials ([see more here](http://support.orcid.org/knowledgebase/articles/116739)):

```ruby
use OmniAuth::Builder do
  provider :orcid, ENV['ORCID_CLIENT_ID'], ENV['ORCID_CLIENT_SECRET']
end
```

To connect to the member API and/or sandbox, use the `member` and/or `sandbox` options, e.g.

```ruby
use OmniAuth::Builder do
  provider :orcid, ENV['ORCID_CLIENT_ID'], ENV['ORCID_CLIENT_SECRET'], member: true, sandbox: true
end
```

OmniAuth takes care of the OAuth external-authentication handshake or "dance". All that the gem does is grab the identifier and tokens at the end of the dance and stick it into the OmniAuth hash which is subsequently accessible to your app via `request.env['omniauth.auth']` (see [AuthHashSchema](https://github.com/intridea/omniauth/wiki/Auth-Hash-Schema)). The hash looks something like this:

```json
{
  "provider": "orcid",
  "uid": "0000-0003-2012-0010",
  "info": {
    "name": "John Smith",
    "email": null
  },
  "credentials": {
    "token": "e82938fa-a287-42cf-a2ce-f48ef68c9a35",
    "refresh_token": "f94c58dd-b452-44f4-8863-0bf8486a0071",
    "expires_at": 1979903874,
    "expires": true
  },
  "extra": {
  }
}
```

You have to implement a callback handler to grab at least the `uid` from the hash and (typically) save it in a session. This effectively provides basic **Log in with your ORCID** functionality.

Most likely, with the token in hand, you'll want to do something more sophisticated with the API, like retrieving profile data and do something cool with it. See the [API documentation](http://members.orcid.org/api/api-calls) for more details:

Here's how to get going with a couple of popular Rack-based frameworks:


### Sinatra

Configure the strategy and implement a callback routine in your app:

```ruby
require 'sinatra'
require 'sinatra/config_file'
require 'omniauth-orcid'
enable :sessions

use OmniAuth::Builder do
  provider :orcid, ENV['ORCID_CLIENT_ID'], ENV['ORCID_CLIENT_SECRET']
end
...
get '/auth/orcid/callback' do
  session[:omniauth] = request.env['omniauth.auth']
  redirect '/'
end

get '/' do

  if session[:omniauth]
    @orcid = session[:omniauth][:uid]
  end
  ..
```

The bundled `demo.rb` file contains an uber-simple working Sinatra example app. Spin it up, point your browser to http://localhost:4567/ and play:

```bash
gem install sinatra
ruby demo.rb
[2012-11-26 21:41:08] INFO  WEBrick 1.3.1
[2012-11-26 21:41:08] INFO  ruby 1.9.3 (2012-04-20) [x86_64-darwin11.3.0]
== Sinatra/1.3.2 has taken the stage on 4567 for development with backup from WEBrick
[2012-11-26 21:41:08] INFO  WEBrick::HTTPServer#start: pid=8383 port=4567

```


### Rails


Add this to `config/initializers/omniauth.rb` to configure the strategy:

```ruby
require 'omniauth-orcid'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :orcid, ENV['ORCID_CLIENT_ID'], ENV['ORCID_CLIENT_SECRET']
end
```

Register a callback path in 'config/routes.rb'

```ruby
..
  match '/auth/:provider/callback' => 'authentications#create'
..
```

Implement a callback handler method in a controller:

```ruby
class AuthenticationsController < ApplicationController
  ..
  def create
    omniauth = request.env["omniauth.auth"]
    session[:omniauth] = omniauth
    session[:params]   = params
    ..
  end
```

## More information

* [ORCID Open Source Project](https://github.com/ORCID/ORCID-Source)
* [Developer Wiki](https://github.com/ORCID/ORCID-Source/wiki)
* [Technical community](http://orcid.org/about/community/orcid-technical-community)


## License

The [MIT License](license.txt) (OSI approved, see more at http://www.opensource.org/licenses/mit-license.php)

![Open Source Initiative Approved License](http://www.opensource.org/trademarks/opensource/web/opensource-110x95.jpg)
