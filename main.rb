if RUBY_PLATFORM.downcase.include?('mswin')
  require 'sinatra/reloader'
end

set :sessions, true

get '/' do
  erb :new_game
end

post '/pre_round' do
  session[:player_name] = params[:player_name]
  session[:player_chips] = params[:player_chips]
  erb :pre_round
end

post '/round' do
  "Hello #{session[:player_name]}, Game ON!!!"
end
