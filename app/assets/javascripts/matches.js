var Matches = {

    init: function() {
        MaterializeSelect.init('#match_local_team_id');
        MaterializeSelect.init('#match_visitor_team_id');
        MaterializeSelect.init('#match_tournament_id');
        Matches.bindSubmitFormAction();
    },

    bindSubmitFormAction: function() {
        $('.match-form').submit(function(e) {
            var day = $(this).find('#match_day').val();
            var month = $(this).find('#match_month').val();
            var year = $(this).find('#match_year').val();
            var hour = $(this).find('#match_hour').val();
            var minute = $(this).find('#match_minute').val();
            var datetime = year+'-'+month+'-'+day+' '+hour+':'+minute;

            $('#match_datetime').each(function () {
                $(this).val(datetime);
            });
        });
    }
};
