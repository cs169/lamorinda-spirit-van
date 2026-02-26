// Using gon if the controller action hasn't set it causes js errors, 
// so as a hack only load this code on pages where its needed
document.addEventListener("turbo:load", function() {
    // Autocomplete for passengers info
    if (gon.passengers) {
      $( function() {
        $( "#ride_passenger_name" ).autocomplete({
          source: gon.passengers
        });

        // Set autocomplete attribute because jquery automatically sets it
        // to "off" after autocomplete function, which doesn't disable Chrome's autofill
        $("#ride_passenger_name").attr("autocomplete", "ride-address");
      } );

      // edits the other fields upon selecting an autocomplete value
      $("#ride_passenger_name").on("autocompleteselect", function (event, ui) {
        const yesNo = (val) => (val ? "Yes" : "No");

        // Update hidden fields
        document.getElementById("ride_passenger_id").value = ui.item.id;
        document.getElementById("ride_wheelchair").value = yesNo(ui.item.wheelchair);
        document.getElementById("ride_disabled").value = yesNo(ui.item.disabled);
        document.getElementById("ride_need_caregiver").value = yesNo(ui.item.need_caregiver);

        // Autofills passenger's address into origin
        document.getElementById("ride_start_address_attributes_street").value = ui.item.street;
        document.getElementById("ride_start_address_attributes_city").value = ui.item.city;

        // Sets the street and city of passenger's home address in edit view
        const passengerHomeAddress = document.getElementById("ride_passenger_home_address");
        if (passengerHomeAddress) {
          passengerHomeAddress.value = ui.item.street + ', ' + ui.item.city;
        };

        // Update passenger overview card
        document.querySelector('#name_display').value = ui.item.label || 'No passenger selected';

        // Bold disabled checkboxes if they are checked
        const updateCheckbox = (id, value) => {
          const checkbox = document.querySelector(`#${id}_display`);
          const label = checkbox.nextElementSibling;
          checkbox.checked = value;
          if (value) {
            checkbox.classList.remove('bg-secondary', 'opacity-50');
            checkbox.classList.add('bg-primary');
            label.classList.add('fw-bold');
          } else {
            checkbox.classList.remove('bg-primary');
            checkbox.classList.add('bg-secondary', 'opacity-50');
            label.classList.remove('fw-bold');
          }
        };

        updateCheckbox('wheelchair', ui.item.wheelchair);
        updateCheckbox('disabled', ui.item.disabled);
        updateCheckbox('need_caregiver', ui.item.need_caregiver);
        updateCheckbox('low_income', ui.item.low_income);
        updateCheckbox('lmv_member', ui.item.lmv_member);

        document.querySelector('#notes_display').value = ui.item.notes || 'No notes available';
        document.querySelector('#phone_display').value = ui.item.phone || 'No number available';
        document.querySelector('#alt_phone_display').value = ui.item.alt_phone || 'No number available';

        // Show/hide new passenger badge based on ride count
        const newPassengerBadge = document.getElementById('new_passenger_badge');
        if (ui.item.ride_count <= 1) {
          newPassengerBadge.style.display = 'block';
        } else {
          newPassengerBadge.style.display = 'none';
        }
      });
    }

    // Autocomplete for addresses
    if (gon.addresses) {
         // Origin address:
      $( function() {
        $( "#ride_start_address_attributes_street" ).autocomplete({
          source: gon.addresses.map(a => ({
              label: a.street,
              value: a.street,
              name: a.name,
              city: a.city,
              phone: a.phone,
          })
          )
        });

        $( "#ride_start_address_attributes_name" ).autocomplete({
          source: gon.addresses
           .filter(a => a.name)
           .map(a => ({
              label: `${a.name}, ${a.street}`,
              value: a.name,
              street: a.street,
              city: a.city,
              phone: a.phone,
           })),
        });

        // Set autocomplete attribute because jquery automatically sets it
        // to "off" after autocomplete function, which doesn't disable Chrome's autofill
        $("#ride_start_address_attributes_street").attr("autocomplete", "ride-address");
        $("#ride_start_address_attributes_name").attr("autocomplete", "ride-address_name");
      });

      $( "#ride_start_address_attributes_name" ).on( "autocompleteselect", function( event, ui ) {
        document.getElementById('ride_start_address_attributes_street').value=  ui.item.street;
        document.getElementById('ride_start_address_attributes_city').value=  ui.item.city;
        document.getElementById('ride_start_address_attributes_phone').value=  ui.item.phone;
      } );

      $( "#ride_start_address_attributes_street" ).on( "autocompleteselect", function( event, ui ) {
        document.getElementById('ride_start_address_attributes_name').value=  ui.item.name;
        document.getElementById('ride_start_address_attributes_city').value=  ui.item.city;
        document.getElementById('ride_start_address_attributes_phone').value=  ui.item.phone;
      } );
      
      // Stop Addresses (uses focus event because stops are added dynamically):
      $(document).on("focus", ".dest-autocomplete", function () {
        const $input = $(this);
        const inputId = this.id; // e.g. ride_dest_address_attributes_1_street or _name
        const isNameField = inputId.endsWith("_name");
        const baseId = inputId.replace(/_(street|name)$/, "");

        const source = isNameField
          ? gon.addresses.filter(a => a.name).map(a => ({
              label: `${a.name}, ${a.street}`,
              value: a.name,
              street: a.street,
              city: a.city,
              phone: a.phone
            }))
          : gon.addresses.map(a => ({
              label: a.street,
              value: a.street,
              name: a.name,
              city: a.city,
              phone: a.phone
            }));
    
        $input.autocomplete({
          source: source,
          select: function (event, ui) {
            $(`#${baseId}_name`).val(ui.item.name)
            $(`#${baseId}_street`).val(ui.item.street);
            $(`#${baseId}_city`).val(ui.item.city);
            $(`#${baseId}_phone`).val(ui.item.phone);
          },

          // Set autocomplete attribute because jquery automatically sets it
          // to "off" after autocomplete function, which doesn't disable Chrome's autofill
          create: function () {
            this.setAttribute("autocomplete", "ride-address");
          },
        });
      });
    }

    // === FIX FOR DUPLICATE RIDE (Stop 1 & Passenger) ===
    if (typeof gon !== 'undefined' && gon.duplicate_info) {
        const info = gon.duplicate_info;

        if (gon.passengers && info.passenger_id) {
            const passengerObj = gon.passengers.find(p => p.id === info.passenger_id);

            if (passengerObj) {
                const passengerInput = $("#ride_passenger_name");

                // A. Visually set the name
                passengerInput.val(passengerObj.label);

                // B. TRIGGER autocomplete logic
                // This manually fires the 'autocompleteselect' event.
                // Our existing code will catch this and fill:
                // - passenger_id hidden field
                // - wheelchair/disabled/caregiver fields
                // - It might also try to fill the Home Address (we will fix that in step C)
                passengerInput.trigger("autocompleteselect", { item: passengerObj });

                // C. Overwrite Start Address
                // We overwrite the "Home Address" immediately after trigger completes.
                if (info.start_address) {
                    const addr = info.start_address;
                    if(addr.name)   $("#ride_start_address_attributes_name").val(addr.name);
                    if(addr.street) $("#ride_start_address_attributes_street").val(addr.street);
                    if(addr.city)   $("#ride_start_address_attributes_city").val(addr.city);
                    if(addr.phone)  $("#ride_start_address_attributes_phone").val(addr.phone);
                }
            }
        }
    }
})
