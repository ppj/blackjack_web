if RUBY_PLATFORM.downcase.include?('w32')
  require 'sinatra/reloader'
end

set :sessions, true

helpers do

  def initialize_deck
    deck_count = 2
    deck = ["S", "H", "C", "D"].product(["A", Array(2..10), "J", "Q", "K"].flatten) * deck_count
    deck.shuffle!
  end


  def total(cards)
    hand_total = 0
    ace_count  = 0
    cards.each do |card|
      if card[1] == 'A'
        ace_count += 1
        hand_total += 11
      elsif card[1].to_i == 0
        hand_total += 10
      else
        hand_total += card[1].to_i
      end
    end

    ace_count.times do
      if hand_total > 21
        hand_total -= 10
      end
    end
    return hand_total
  end


end

# routes
get '/' do
  erb :new_game
end


post '/set_player_profile' do
  session[:player_name]  = params[:player_name]
  session[:player_chips] = params[:player_chips]
  redirect :pre_round
end


get '/pre_round' do
  erb :pre_round
end


post '/begin_round' do
  session[:player_bet] = params[:player_bet]
  session[:deck] = initialize_deck
  session[:player_cards] = []
  session[:dealer_cards] = []
  2.times {
    session[:player_cards] << session[:deck].pop
    session[:dealer_cards] << session[:deck].pop
  }
  redirect :game
end


post '/game/player/hit' do
  if total(session[:player_cards]) < 21
    session[:player_cards] << session[:deck].pop
    redirect :game
  end

  if total(session[:player_cards]) > 21
    session[:alert] = "#{session[:player_name]} busted!"
    redirect :game_over
  elsif total(session[:player_cards]) == 21
    if total(session[:dealer_cards]) == 21
      session[:alert] = "Game pushes"
    else
      session[:alert] = "#{session[:player_name]} hit a BlackJack!}"
    end
    redirect :game_over
  end
end


post '/game/player/stay' do
  while total(session[:dealer_cards]) < 18
    session[:dealer_cards] << session[:deck].pop
  end
  if total(session[:dealer_cards]) <= 21
    redirect :game
  end

  if total(session[:dealer_cards]) > 21
    session[:alert] = "Dealer busted! #{session[:player_name]} wins!"
    redirect :game_over
  end
end


get '/game' do
  erb :game
end


get '/game_over' do
  @error = session[:alert]
  erb :game_over
end


