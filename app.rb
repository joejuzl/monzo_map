require 'sinatra'
require 'oauth'
require 'http'
require 'dotenv'
require 'omniauth'
require 'omniauth-mondo'
require 'sprockets'

require_relative 'lib/monzo_map/client'

Dotenv.load

class App < Sinatra::Base
  enable :sessions

  # OAuth
  use OmniAuth::Builder do
    provider :mondo, ENV['MONDO_KEY'], ENV['MONDO_SECRET'], { :provider_ignores_state => true }
  end

  get '/auth/mondo/callback' do
    auth = env['omniauth.auth']
    session[:account_id] = auth[:uid]
    session[:account_name] = auth[:info][:name]
    session[:token] = auth[:credentials][:token]
    redirect '/'
  end

  def client
    redirect '/auth/mondo' unless session[:token]
    @client ||= MonzoMap::Client.new(access_token: session[:token], account_id: session[:account_id])
  end

  # Assets
  set :environment, Sprockets::Environment.new
  environment.append_path 'assets/stylesheets'
  environment.append_path 'assets/javascripts'
  get '/assets/*' do
    env['PATH_INFO'].sub!('/assets', '')
    settings.environment.call(env)
  end

  # App routes
  get '/' do
    erb :index, locals: { points: client.points }
  end

  get '/balance' do
    client.balance
  end
end
