var Tables = {
    init: function() {
        MaterializeSelect.init('#table_match_ids');
        MaterializeSelect.init('#table_tournament_id');
        Tables.bindCloseTableActions();
        Tables.bindFilterMatchesOptionsByTournament();
    },

    bindCloseTableActions: function() {
        $('.close-table-link').on('click', function (e) {
            e.preventDefault();
            $('#close-table-form').attr('action', $(this).data('link')).submit();
        });
    },

    bindFilterMatchesOptionsByTournament: function() {
        $('#table_tournament_id').on('change', function () {
            var options = $('#matches_by_tournaments').find('li[data-tournament-id="'+this.value+'"]').html();
            $('#table_match_ids').empty();
            $('#table_match_ids').append(options);
            MaterializeSelect.init('#table_match_ids');
        });
    }
};
