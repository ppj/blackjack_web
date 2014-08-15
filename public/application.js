$(document).ready(function() {

  $(document).on('click', '#hit_form input', function() {
    $.ajax({
      type: 'POST',
      url: '/round/player/hit'
    }).done(function(msg) {
      $('#game_area').replaceWith(msg);
    });
    // prevent from further execution of the route
    return false; // or event.preventDefault();
  });



});
