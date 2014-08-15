if RUBY_PLATFORM.downcase.include?('w32')
  require 'sinatra/reloader'
end

set :sessions, true

BLACKJACK_VALUE = 21
DEALER_HIT_MIN  = 17

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
      if hand_total > BLACKJACK_VALUE
        hand_total -= 10
      end
    end
    hand_total
  end


  def card_image(card)
    "<img src='/images/cards2/#{card.join}.gif' class='img-rounded card-image' />"
  end


  def game_won(msg)
    @success = "<strong>#{session[:player_name]} won!</strong> #{msg}"
    session[:player_chips] += session[:player_bet]
  end

  def game_lost(msg)
    @error = "<strong>#{session[:player_name]} lost.</strong> #{msg}"
    session[:player_chips] -= session[:player_bet]
  end

  def game_pushed(msg)
    @info = "<strong>Game pushed!</strong> #{msg}"
  end

  def player_hit_blackjack_or_busted?
    player_total = total(session[:player_cards])
    dealer_total = total(session[:dealer_cards])
    if player_total == BLACKJACK_VALUE
      if dealer_total == BLACKJACK_VALUE
        game_pushed "Both #{session[:player_name]} and Dealer hit BlackJack!"
      else
        game_won "#{session[:player_name]} hit a BlackJack! Dealer had #{dealer_total}."
      end
      return true
    elsif player_total > BLACKJACK_VALUE
      game_lost "#{session[:player_name]} busted @ #{player_total}. Dealer had #{dealer_total}."
      return true
    else
      @show_hit_stay_buttons = true
      return false
    end
  end


  def dealer_hit_blackjack_or_busted?
    player_total = total(session[:player_cards])
    dealer_total = total(session[:dealer_cards])
    if dealer_total == BLACKJACK_VALUE
      game_lost "Dealer hit a BlackJack! #{session[:player_name]} stayed @ #{player_total}."
      return true
    elsif dealer_total > BLACKJACK_VALUE
      game_won "Dealer busted @ #{dealer_total}! #{session[:player_name]} stayed @ #{player_total}."
      return true
    elsif dealer_total <= DEALER_HIT_MIN
      @show_dealer_hit_button = true
    end
    return false
  end


  def check_game_result
    player_total = total(session[:player_cards])
    dealer_total = total(session[:dealer_cards])
    if dealer_total == player_total
      game_pushed "#{session[:player_name]} and Dealer stayed @ #{player_total}"
    elsif dealer_total < player_total
      game_won  "Dealer stayed @ #{dealer_total}. #{session[:player_name]} stayed @ #{player_total}."
    else
      game_lost "Dealer stayed @ #{dealer_total}. #{session[:player_name]} stayed @ #{player_total}."
    end
  end


end


# before do
  # @show_hit_stay_buttons = true
# end


# routes
get '/' do
  erb :new_round
end


post '/round/new' do
  if params[:player_name].strip.empty?
    @error = "Name cannot be blank"
    halt erb(:new_round)
  end
  if params[:player_chips].to_i <= 0
    @error = 'Please start with valid number of chips'
    halt erb(:new_round)
  end
  session[:player_name]  = params[:player_name]
  session[:player_chips] = params[:player_chips].to_i
  session[:player_bet]   = session[:player_chips]/5
  session[:deck]         = initialize_deck

  redirect '/place_bet'
end


get '/place_bet' do
  erb :place_bet
end


post '/round/begin' do
  if params[:player_bet].to_i == 0
    @error = "Please place a valid bet, #{session[:player_name]}. Bet set to previous value."
    halt erb(:place_bet)
  elsif params[:player_bet].to_i > session[:player_chips]
    session[:player_bet] = session[:player_chips]
    @error = "You have only #{session[:player_chips]} chips remaining! Bet set to #{session[:player_chips]}."
    halt erb(:place_bet)
  end

  session[:player_bet]   = params[:player_bet].to_i
  session[:deck]         = initialize_deck if session[:deck].size < 20
  session[:player_cards] = []
  session[:dealer_cards] = []
  session[:player_stays] = false
  2.times {
    session[:player_cards] << session[:deck].pop
    session[:dealer_cards] << session[:deck].pop
  }
  redirect '/round/player'
end


get '/round/player' do
  # FIXME - if player hits blackjack, two success msgs are shown
  # FIXME - above route should be renamed to /round since that url is shown for the both, player's and dealer's turns
  player_hit_blackjack_or_busted?
  if params[:hide_layout]
    erb :round, layout: false
  else
    erb :round
  end

end

# Ajaxified!
post '/round/player/hit' do
  session[:player_cards] << session[:deck].pop
  redirect '/round/player?hide_layout=true'
end


post '/round/player/stay' do
  redirect '/round/dealer?hide_layout=true'
end


get '/round/dealer' do
  dealer_total = total(session[:dealer_cards])
  if !dealer_hit_blackjack_or_busted? & (dealer_total > DEALER_HIT_MIN)
    redirect '/round/compare'
  elsif params[:hide_layout]
    erb :round, layout: false
  else
    erb :round
  end
end


post '/round/dealer/hit' do
  session[:dealer_cards] << session[:deck].pop
  redirect '/round/dealer?hide_layout=true'
end


get '/round/compare' do
  check_game_result
  erb :round, layout: false
end


post '/play_again' do
  redirect '/place_bet'
end


get '/game_over' do
  erb :game_over
end
