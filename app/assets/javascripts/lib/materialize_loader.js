var MaterializeLoader = {

    init: function() {
        MaterializeLoader.initTextAreas();
        MaterializeLoader.initInputs();
        MaterializeLoader.initSelectors();
        MaterializeLoader.initDatePickers();
    },

    initTextAreas: function () {
        $(document.body).on('keyup keydown', 'textarea', function () {
            MaterializeLoader.textareaAutoResize($(this))
        });
        $('textarea').each(function () {
            if ($(this).val().length) MaterializeLoader.textareaAutoResize($(this));
        });
    },

    initInputs: function () {
        $('input, textarea').each(function (index, el) {
            MaterializeLoader.initInputField($(this));
        });
    },

    initSelectors: function () {
        $('select').each(function (index, el) {
            MaterializeLoader.initSelectField($(this));
            $(this).change(function(){ MaterializeLoader.fixLabelAndIconStyles($(this)); });
        });
    },

    initDatePickers: function() {
        $('.datepicker').pickadate({
            selectMonths: true,         // Creates a dropdown to control month
            selectYears: 15             // Creates a dropdown of 15 years to control year
        });
    },

    initInputField: function(object) {
        if(object.val() && object.val() != '') {
            MaterializeLoader.activateLabelAndIcon(object);
            validate_field(object);
        }
    },

    initSelectField: function(object) {
        if(object.val() && object.val() != '') {
            MaterializeLoader.activateLabelAndIcon(object);
            validate_field(object);
        }
    },

    fixLabelAndIconStyles: function(selector) {
        if($(selector).parent().find('.select-dropdown').val().length > 0) MaterializeLoader.activateLabelAndIcon($(selector));
        else MaterializeLoader.deactivateLabelAndIcon($(selector));
    },

    activateIcon: function(input_object) {
        input_object.siblings('i').addClass('active');
    },

    activateLabelAndIcon: function(input_object) {
        if(input_object.parent().hasClass('field_with_errors')) {
            MaterializeLoader.activateIcon(input_object.parent());
            var label = input_object.parent().parent().find('label');
            if(label.size() > 0) {
                label.addClass('active');
                MaterializeLoader.indentForForms(label);
                MaterializeLoader.indentForForms(input_object);
            }
        }
        else {
            input_object.siblings('label').addClass('active');
            MaterializeLoader.activateIcon(input_object);
        }
    },

    deactivateLabelAndIcon: function(input_object) {
        input_object.siblings('label').removeClass('active');
        input_object.siblings('i').removeClass('active');
    },

    textareaAutoResize: function($textarea) {
        var hiddenDiv = $('.hiddendiv').first();
        if (!hiddenDiv.length) {
            hiddenDiv = $('<div class="hiddendiv common"></div>');
            $('body').append(hiddenDiv);
        }
        // Set fontsize of hiddenDiv
        var fontSize = $textarea.css('font-size');
        if (fontSize) hiddenDiv.css('font-size', fontSize);
        hiddenDiv.text($textarea.val() + '\n');
        var content = hiddenDiv.html().replace(/\n/g, '<br>');
        hiddenDiv.html(content);

        // When textarea is hidden, width goes crazy.
        // Approximate with half of window size
        if ($textarea.is(':visible')) hiddenDiv.css('width', $textarea.width());
        else hiddenDiv.css('width', $(window).width()/2);
        $textarea.css('height', hiddenDiv.height());
    },

    indentForForms: function(object) {
        //object.css({ 'margin-top': '3rem', 'width': 'calc(100% - 3rem)' });
    }

};