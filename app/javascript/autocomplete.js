document.addEventListener("turbo:load", function() {
    // using gon if the controller action hasn't set it causes js errors, so as a hack only load this code on pages where its needed
    if (document.getElementById("ride_passenger_name")){

      // basic autocomplete setup
      $( function() {
        $( "#ride_passenger_name" ).autocomplete({
          source: gon.passengers
        });
      } );

      // edits the other fields upon selecting an autocomplete value
      $( "#ride_passenger_name" ).on( "autocompleteselect", function( event, ui ) {
        const yesNo = (val) => val ? "Yes" : "No";

        document.getElementById('ride_passenger_phone').value=  ui.item.phone;
        document.getElementById('ride_passenger_wheelchair').value=  yesNo(ui.item.wheelchair);
        document.getElementById('ride_passenger_low_income').value=  yesNo(ui.item.low_income);
        document.getElementById('ride_passenger_disabled').value=  yesNo(ui.item.disabled);
        document.getElementById('ride_passenger_need_caregiver').value=  yesNo(ui.item.need_caregiver);
        document.getElementById('ride_passenger_notes').value=  ui.item.notes;
        document.getElementById('ride_passenger_id').value=  ui.item.id;
      } );


      //Addresses:
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
      
      //Addresses:
      $( function() {
        $( "#ride_dest_address_attributes_street" ).autocomplete({
          source: gon.addresses
        });
        $("#ride_dest_address_attributes_street").attr("autocomplete", "ride-address");
      } );

      $( "#ride_dest_address_attributes_street" ).on( "autocompleteselect", function( event, ui ) {
        document.getElementById('ride_dest_address_attributes_city').value=  ui.item.city;
        document.getElementById('ride_dest_address_attributes_state').value=  "CA";
        document.getElementById('ride_dest_address_attributes_zip').value=  ui.item.zip;
      } );

    }
  })

  /*
   // E
   document.addEventListener('change', (event) => {
    if (event.target.matches('#ride_passenger_name')) {
      document.getElementById('ride_notes_date_reserved').value=  gon.passengers;
    }
  });*/