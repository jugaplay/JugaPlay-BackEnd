//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require turbolinks
//= require bootstrap-sprockets
//= require materialize-sprockets
//= require_tree .

$(document).on('ready page:load', function () {
    MaterializeLoader.init();
    Tables.init();
    Matches.init();
    Players.init();

    $('.collapsible').collapsible();
    $('.button-collapse').sideNav();
});
