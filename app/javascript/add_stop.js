document.addEventListener("turbo:load", function () {
  const addButton = document.getElementById("add-stop-button");
  const deleteButton = document.getElementById("delete-stop-button");
  const addressGrid = document.getElementById("address-grid");
  const stopsContainer = document.getElementById("stops-container");
  const template = document.getElementById("destination-template");

  if (!addButton || !deleteButton || !stopsContainer || !template) {
    return;
  }

  let index = parseInt(addressGrid?.dataset?.lastIndex, 10) + 1 || 2;

  // 1. Helper to Populate Driver Dropdown
  function populateDriverSelect(selectElement, selectedDriverId = null) {
    let driversData = (typeof gon !== 'undefined' && gon.drivers) ? gon.drivers : [];

    selectElement.innerHTML = '<option value="">Select a Driver</option>';
    // Add driver options
    driversData.forEach(function(driver) {
      const option = document.createElement('option');
      option.value = driver.id;
      option.textContent = driver.name;
      if (selectedDriverId && String(driver.id) === String(selectedDriverId)) {
        option.selected = true;
      }
      selectElement.appendChild(option);
    });
  }

  // 2. The Core Logic: Adds a stop row and fills it with data
  function addStopRow(data = null) {
    try {
      const html = template.innerHTML.replace(/__INDEX__/g, index);
      const wrapper = document.createElement("div");
      wrapper.innerHTML = html;
      const newRow = wrapper.firstElementChild;

      if (newRow) {
        // A. Handle Driver Dropdown
        const driverSelect = newRow.querySelector('.driver-select');
        if (driverSelect) {
          populateDriverSelect(driverSelect, data ? data.driver_id : null);
        }

        // B. Handle Address Pre-fill (If data is provided from Duplicate)
        if (data) {
          // Selectors match `name="ride[addresses_attributes][2][name]"` style
          const nameInput   = newRow.querySelector('[name$="[name]"]');
          const phoneInput  = newRow.querySelector('[name$="[phone]"]');
          const streetInput = newRow.querySelector('[name$="[street]"]');
          const cityInput   = newRow.querySelector('[name$="[city]"]');
          const vanInput    = newRow.querySelector('[name$="[van]"]');

          if (nameInput)   nameInput.value   = data.name || '';
          if (phoneInput)  phoneInput.value  = data.phone || '';
          if (streetInput) streetInput.value = data.street || '';
          if (cityInput)   cityInput.value   = data.city || '';
          if (vanInput)    vanInput.value    = data.van || '';
        }

        // Add the new stop card to the stops container
        stopsContainer.appendChild(newRow);

        if (addressGrid) addressGrid.dataset.lastIndex = index;
        index++;
      }
    } catch (error) {
      console.error("Error adding stop:", error);
    }
  }

  // 3. Event Listeners
  addButton.addEventListener("click", () => addStopRow()); // Manual click = empty row

  deleteButton.addEventListener("click", function () {
    // Prevent deleting the initial destination
    if (stopsContainer.children.length > 1) {
        stopsContainer.removeChild(stopsContainer.lastElementChild);
        if (addressGrid) addressGrid.dataset.lastIndex = index;
        index--;
    }
  });

  // 4. AUTO-GENERATION: Check for 'duplicated_stops' from Controller
  if (typeof gon !== 'undefined' && gon.duplicated_stops && gon.duplicated_stops.length > 0) {
    gon.duplicated_stops.forEach(stopData => {
      addStopRow(stopData);
    });
  }
});
