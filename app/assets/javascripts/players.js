var Players = {
    init: function() {
        MaterializeSelect.init('#player_team_id');
        MaterializeSelect.init('#player_position');
        MaterializeSelect.init('#player_nationality');
        Players.bindSubmitFormAction();
    },

    bindSubmitFormAction: function() {
        $('.player-form').submit(function(e) {
            var day = $(this).find('#player_day').val();
            var month = $(this).find('#player_month').val();
            var year = $(this).find('#player_year').val();
            var birthday = year+'-'+month+'-'+day;

            $('#player_birthday').each(function () {
                $(this).val(birthday);
            });
        });
    }
};
