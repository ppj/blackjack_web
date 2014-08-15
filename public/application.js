$(document).ready(function() {

  $('#hit_form input').click(function() {
    $.ajax({
      type: 'POST',
      url: '/round/player/hit'
    }).done(function(msg) {
      $('#game_area').html(msg);
    });
    // prevent from further execution of the route
    return false; // or event.preventDefault();
  });



});
