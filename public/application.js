$(document).ready(function() {

  player_hits();
  player_stays();
  dealer_hits();

});

function player_hits() {
  $(document).on('click', '#player_hit_form input', function() {
    $.ajax({
      type: 'POST',
      url: '/round/player/hit'
    }).done(function(msg) {
      $('#game_area').replaceWith(msg);
    });
    // prevent from further execution of the route
    return false; // or event.preventDefault();
  });
}

function player_stays() {
  $(document).on('click', '#player_stay_form input', function() {
    $.ajax({
      type: 'POST',
      url: '/round/player/stay'
    }).done(function(msg) {
      $('#game_area').replaceWith(msg);
    });
    // prevent from further execution of the route
    return false; // or event.preventDefault();
  });
}

function dealer_hits() {
  $(document).on('click', '#dealer_hit_form input', function() {
    $.ajax({
      type: 'POST',
      url: '/round/dealer/hit'
    }).done(function(msg) {
      $('#game_area').replaceWith(msg);
    });
    // prevent from further execution of the route
    return false; // or event.preventDefault();
  });
}
