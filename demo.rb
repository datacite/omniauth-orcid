# ORCID example client application in Sinatra.
#
# Modelled after this app: https://github.com/zuzara/jQuery-OAuth-Popup

require 'rubygems'
require 'sinatra'
require 'haml'
require_relative 'lib/omniauth-orcid'
require 'oauth2'
require 'json'

enable :sessions
use Rack::Session::Cookie

if development?
  puts "Sinatra running in development mode"
elsif production?
  puts "Sinatra running in production mode"
end

puts "Connecting to ORCID API at " + settings.site + " as client app #{settings.client_id}"

# Configure the ORCID strategy
use OmniAuth::Builder do
  provider :orcid, ENV['ORCID_CLIENT_ID'], ENV['ORCID_CLIENT_SECRET'],
    authorize_params: {
      scope: '/orcid-profile/read-limited'
    },
  client_options: {
    site: ENV['ORCID_URL'],
    authorize_url: "#{ENV['ORCID_URL']}/oauth/authorize",
    token_url: "#{ENV['ORCID_URL']}/oauth/token",
  }
end




get '/' do

  @orcid = ''

  if session[:omniauth]
    @orcid = session[:omniauth][:uid]
  end
  haml <<-HTML
%html
  %head
    %title ORCID OmniAuth demo app
  %body
    - if session[:omniauth]
      %p
        Signed in with ORCiD <b>#{@orcid}</b>
        %a(href="/signout") sign out
      %p
        %a(href="/user_info")Show OmniAuth user data as JSON
      %p
        %a(href="/orcid_profile")Connect to ORCID API to fetch full profile data as JSON
    - else
      %p
        %a(href="/auth/orcid") Log in with my ORCiD
  HTML
end


get '/user_info' do
  content_type :json
  session[:omniauth].to_json
end


get '/auth/orcid/callback' do
  puts "Adding OmniAuth user info to session: " +  request.env['omniauth.auth'].inspect
  session[:omniauth] = request.env['omniauth.auth']
  redirect '/'
end

get '/orcid_profile' do
  client = OAuth2::Client.new settings.client_id,settings.client_secret, :site  => settings.site
  atoken = OAuth2::AccessToken.new client, session[:omniauth]['credentials']['token']
  response = atoken.get "/#{session[:omniauth]['uid']}/orcid-profile", :headers => {'Accept' => 'application/json'}
  response.body
end


get '/signout' do
  session.clear
  redirect '/'
end


