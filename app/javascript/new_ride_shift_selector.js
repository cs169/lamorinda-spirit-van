  
function get_and_set_shifts(date, chosen_shift=null) {
    var request = $.ajax({
        url: "/shifts/shifts_for_day",
        data: { date: date },
        dataType: "json"
      });
       
    request.done(function( new_options ) {
        var $el = $("#ride_shift_id");

        $el.empty();
        $.each(new_options, function(index) {
            var option =  new_options[index];
            $el.append($("<option></option>").attr("value", option.value).text(option.text));
            });
        if (chosen_shift) {
            $(`#ride_shift_id option[value="${chosen_shift}"]`).attr('selected', true);
        }
      });
}


document.addEventListener('change', (event) => {
    if (event.target.matches('#ride_shift_date')) {
        get_and_set_shifts(event.target.value)
    }
});


// if you come from a shift page, it should automatically select that shift for you
document.addEventListener('turbo:load', function() {
    //check if we're on the new ride page
    if (document.getElementById("ride_passenger_name")){
        var date = $("#ride_shift_date").attr("value")
        if (date){   
            var shift_id = $("#ride_shift_id").attr("value")
            get_and_set_shifts(date, shift_id)
        }
    }
});


// // stolen from: https://stackoverflow.com/a/6364838
// var new_options = response.options;

// /* Remove all options from the select list */
// $('yourSelectList').empty();

// /* Insert the new ones from the array above */
// $.each(new_options, function(value) {
//     new Element('option')
//         .set('text', value)
//         .inject($('yourSelectList'));
//     });