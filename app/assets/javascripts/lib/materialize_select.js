var MaterializeSelect = {

    init: function(selector) {
        $(selector).material_select();
        MaterializeSelect.fixStyles(selector);
    },

    fixStyles: function(selector) {
        if($(selector).parent().siblings('label').size() > 0)
            MaterializeLoader.indentForForms($(selector).parent());
    }

};
