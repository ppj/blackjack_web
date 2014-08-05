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
  session[:alert] = ""
  session[:player_name]  = params[:player_name]
  session[:player_chips] = params[:player_chips].to_i
  redirect :pre_round
end


get '/pre_round' do
  erb :pre_round
end


post '/begin_round' do
  session[:player_bet] = params[:player_bet].to_i
  session[:deck] = initialize_deck
  session[:player_cards] = []
  session[:dealer_cards] = []
  session[:player_stays] = false
  2.times {
    session[:player_cards] << session[:deck].pop
    session[:dealer_cards] << session[:deck].pop
  }
  redirect :game
end


get '/game' do
  unless  session[:player_stays]
    if total(session[:player_cards]) == 21
      if total(session[:dealer_cards]) == 21
        @error = "Both #{session[:player_name]} and Dealer hit BlackJack! Game pushes"
      else
        @error = "#{session[:player_name]} hit a BlackJack!"
        session[:player_chips] += session[:player_bet]
      end
    elsif total(session[:player_cards]) > 21
      @error = "#{session[:player_name]} busted!"
      session[:player_chips] -= session[:player_bet]
    end
  else
    if total(session[:dealer_cards]) == 21
      @error = "Dealer hit a BlackJack!"
      session[:player_chips] -= session[:player_bet]
    elsif total(session[:dealer_cards]) > 21
      @error = "Dealer busted @ #{total(session[:dealer_cards])}! #{session[:player_name]} wins!"
      session[:player_chips] += session[:player_bet]
    elsif total(session[:player_cards]) == total(session[:dealer_cards])
      @error = "#{session[:player_name]} and Dealer stay @ #{total(session[:player_cards])}! Game pushes"
    elsif total(session[:player_cards]) > total(session[:dealer_cards])
      @error = "#{session[:player_name]} wins. Dealer stays @ #{total(session[:dealer_cards])}"
      session[:player_chips] += session[:player_bet]
    else
      @error = "Dealer wins @ #{total(session[:dealer_cards])}"
      session[:player_chips] -= session[:player_bet]
    end
  end

  erb :game
end


post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop
  redirect :game
end


post '/game/player/stay' do
  session[:player_stays] = true
  while total(session[:dealer_cards]) < 18
    session[:dealer_cards] << session[:deck].pop
  end

  redirect :game

end


post '/play_again' do
  redirect :pre_round
end


get '/game_over' do
  erb :game_over
end
