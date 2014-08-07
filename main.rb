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
    hand_total
  end


  def card_image(card)
    "<img src='/images/cards2/#{card.join}.gif' class='img-rounded card-image' />"
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
  session[:error]        = nil
  redirect '/place_bet'
end


get '/place_bet' do
  erb :place_bet
end


post '/round/begin' do
  if params[:player_bet].to_i > session[:player_chips]
    @error = "You have only #{session[:player_chips]} chips remaining!"
    halt erb(:place_bet)
  elsif params[:player_bet].to_i == 0
    @error = "Please place a valid bet, #{session[:player_name]}."
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
  player_total = total(session[:player_cards])
  dealer_total = total(session[:dealer_cards])
  if player_total == 21
    if dealer_total == 21
      @info = "Both #{session[:player_name]} and Dealer hit BlackJack! Game pushes"
    else
      @success = "#{session[:player_name]} hit a BlackJack!"
      session[:player_chips] += session[:player_bet]
    end
  elsif player_total > 21
    @error = "#{session[:player_name]} busted!"
    session[:player_chips] -= session[:player_bet]
  else
    @show_hit_stay_buttons = true
  end

  erb :round

end


post '/round/player/hit' do
  session[:player_cards] << session[:deck].pop
  redirect '/round/player'
end


post '/round/player/stay' do
  redirect '/round/dealer'
end


get '/round/dealer' do
  player_total = total(session[:player_cards])
  dealer_total = total(session[:dealer_cards])
  if dealer_total == 21
    @error = "Dealer hit a BlackJack!"
    session[:player_chips] -= session[:player_bet]
  elsif dealer_total > 21
    @success = "Dealer busted @ #{dealer_total}! #{session[:player_name]} wins!"
    session[:player_chips] += session[:player_bet]
  elsif dealer_total <= 17
    @show_dealer_hit_button = true
  else
    redirect '/round/compare'
  end

  erb :round
end


post '/round/dealer/hit' do
  session[:dealer_cards] << session[:deck].pop
  redirect '/round/dealer'
end


get '/round/compare' do
  player_total = total(session[:player_cards])
  dealer_total = total(session[:dealer_cards])
  if dealer_total == player_total
    @info = "#{session[:player_name]} and Dealer stay @ #{player_total}! Game pushes"
  elsif dealer_total < player_total
    @success = "#{session[:player_name]} wins. Dealer stays @ #{dealer_total}"
    session[:player_chips] += session[:player_bet]
  else
    @error = "Dealer wins @ #{dealer_total}"
    session[:player_chips] -= session[:player_bet]
  end

  erb :round
end


post '/play_again' do
  redirect '/place_bet'
end


get '/game_over' do
  erb :game_over
end
