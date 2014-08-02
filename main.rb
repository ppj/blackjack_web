require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

set :sessions, true

get '/' do
  # "Hello, Stupendous Saravanan!"
  erb :set_name
end


post '/buy_chips' do
  session[:player_name] = params[:player_name]
  erb :buy_chips

end


post '/pre_round' do
  session[:player_chips] = params[:player_chips]
  erb :pre_round
end

post '/round' do
  "Hello #{session[:player_name]}, Game ON!!!"
end
