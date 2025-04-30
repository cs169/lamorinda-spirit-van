// Using gon if the controller action hasn't set it causes js errors, 
// so as a hack only load this code on pages where its needed
document.addEventListener("turbo:load", function() {
    // Autocomplete for passengers info
    if (gon.passengers) {
      $( function() {
        $( "#ride_passenger_name" ).autocomplete({
          source: gon.passengers
        });
      } );

      // edits the other fields upon selecting an autocomplete value
      $("#ride_passenger_name").on("autocompleteselect", function (event, ui) {
        const yesNo = (val) => (val ? "Yes" : "No");
        document.getElementById("ride_passenger_phone").value = ui.item.phone;
        document.getElementById("ride_wheelchair").value = yesNo(ui.item.wheelchair);
        document.getElementById("ride_low_income").value = yesNo(ui.item.low_income);
        document.getElementById("ride_disabled").value = yesNo(ui.item.disabled);
        document.getElementById("ride_need_caregiver").value = yesNo(ui.item.need_caregiver);
        document.getElementById("ride_passenger_notes").value = ui.item.notes;
        document.getElementById("ride_passenger_id").value = ui.item.id;
      });
    }

    // Autocomplete for addresses
    if (gon.addresses) {
         // Origin address:
      $( function() {
        $( "#ride_start_address_attributes_street" ).autocomplete({
          source: gon.addresses
        });
        // set autocomplete attribute to "ride-address" because jquery automatically sets it to "off", which is useless.
        $("#ride_start_address_attributes_street").attr("autocomplete", "ride-address");
      } );

      $( "#ride_start_address_attributes_street" ).on( "autocompleteselect", function( event, ui ) {
        document.getElementById('ride_start_address_attributes_city').value=  ui.item.city;
        document.getElementById('ride_start_address_attributes_state').value=  "CA";
        document.getElementById('ride_start_address_attributes_zip').value=  ui.item.zip;
      } );
      
      // // Stop Addresses (uses focus event because stops are added dynamically):
      $(document).on("focus", ".dest-autocomplete", function () {
        const $input = $(this);
    
        // Avoid re-initializing if already initialized
        // if ($input.data("ui-autocomplete")) return;
    
        $input.autocomplete({
          source: gon.addresses,
          select: function (event, ui) {
            const inputId = this.id;               // ex. "ride_dest_address_attributes_1_street"
            const baseId = inputId.replace(/_street$/, ""); // remove "_street" suffix
  
            $(`#${baseId}_city`).val(ui.item.city);
            $(`#${baseId}_state`).val("CA");
            $(`#${baseId}_zip`).val(ui.item.zip);
          }
        });
      });
      }
  })