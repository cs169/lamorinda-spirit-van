document.addEventListener("turbo:load", function () {
  const addressGrid = document.getElementById("address-grid");
  const stopsContainer = document.getElementById("stops-container");
  const template = document.getElementById("destination-template");

  if (!stopsContainer || !template) {
    return;
  }

  let index = parseInt(addressGrid?.dataset?.lastIndex, 10) + 1 || 2;

  // Get drivers data from gon
  let driversData = [];
  if (typeof gon !== "undefined" && gon.drivers) {
    driversData = gon.drivers;
  }

  // Helper to populate driver dropdown
  function populateDriverSelect(selectElement, selectedDriverId = null) {
    selectElement.innerHTML = '<option value="">Select a Driver</option>';

    driversData.forEach(function (driver) {
      const option = document.createElement("option");
      option.value = driver.id;
      option.textContent = driver.name;
      if (selectedDriverId && String(driver.id) === String(selectedDriverId)) {
        option.selected = true;
      }
      selectElement.appendChild(option);
    });
  }

  // Add a stop row, optionally prefilled with duplicated-stop data
  function addStopRow(data = null, insertAfterStopUnit = null) {
    try {
      const html = template.innerHTML.replace(/__INDEX__/g, index);
      const wrapper = document.createElement("div");
      wrapper.innerHTML = html;

      const newStop = wrapper.querySelector(".col-md-12.mb-4");
      if (!newStop) return;

      // Populate driver dropdown in the new stop
      const driverSelect = newStop.querySelector(".driver-select");
      if (driverSelect) {
        populateDriverSelect(driverSelect, data ? data.driver_id : null);
      }

      // Prefill duplicated stop data
      if (data) {
        const nameInput = newStop.querySelector('[name$="[name]"]');
        const phoneInput = newStop.querySelector('[name$="[phone]"]');
        const streetInput = newStop.querySelector('[name$="[street]"]');
        const cityInput = newStop.querySelector('[name$="[city]"]');
        const vanInput = newStop.querySelector('[name$="[van]"]');

        if (nameInput) nameInput.value = data.name || "";
        if (phoneInput) phoneInput.value = data.phone || "";
        if (streetInput) streetInput.value = data.street || "";
        if (cityInput) cityInput.value = data.city || "";
        if (vanInput) vanInput.value = data.van || "";
      }

      if (insertAfterStopUnit) {
        insertAfterStopUnit.insertAdjacentElement("afterend", newStop);
      } else {
        stopsContainer.appendChild(newStop);
      }

      reindexStops();

      if (addressGrid) addressGrid.dataset.lastIndex = index - 1;
    } catch (error) {
      console.error("Error adding stop:", error);
    }
  }

  // Add stop button event (delegated)
  stopsContainer.addEventListener("click", function (e) {
    const btn = e.target.closest(".add-stop-button");
    if (!btn) return;

    try {
      const stopUnit = btn.closest(".col-md-12.mb-4");
      if (!stopUnit) return;

      addStopRow(null, stopUnit);
    } catch (error) {
      console.error("Error adding stop:", error);
    }
  });

  // Delete button event
  stopsContainer.addEventListener("click", function (e) {
    const btn = e.target.closest(".delete-stop-button");
    if (!btn) return;

    try {
      const stopUnit = btn.closest(".col-md-12.mb-4");
      if (!stopUnit) return;

      const units = stopsContainer.querySelectorAll(".col-md-12.mb-4");
      if (units.length <= 1) return; // Need at least one stop

      stopUnit.remove();
      reindexStops();
    } catch (error) {
      console.error("Error deleting stop:", error);
    }
  });

  // Swap up / down event
  stopsContainer.addEventListener("click", function (e) {
    const upBtn = e.target.closest(".swap-up-button");
    const downBtn = e.target.closest(".swap-down-button");
    if (!upBtn && !downBtn) return;

    e.preventDefault();

    const stopUnit = e.target.closest(".col-md-12.mb-4");
    if (!stopUnit) return;

    if (upBtn) {
      const prev = stopUnit.previousElementSibling;
      if (!prev) return;
      stopsContainer.insertBefore(stopUnit, prev);
    } else {
      const next = stopUnit.nextElementSibling;
      if (!next) return;
      stopsContainer.insertBefore(next, stopUnit);
    }

    reindexStops();
  });

  function reindexStops() {
    const units = stopsContainer.querySelectorAll(".col-md-12.mb-4");

    units.forEach((unit, i) => {
      const newIndex = i + 1;

      const header = unit.querySelector(".card-header h6");
      if (header) header.textContent = `Stop ${newIndex}`;

      unit.querySelectorAll("[id]").forEach((el) => {
        el.id = rewriteIndexedId(el.id, newIndex);
      });

      unit.querySelectorAll("label[for]").forEach((label) => {
        label.htmlFor = rewriteIndexedId(label.htmlFor, newIndex);
      });

      const up = unit.querySelector(".swap-up-button");
      const down = unit.querySelector(".swap-down-button");
      if (up) up.disabled = i === 0;
      if (down) down.disabled = i === units.length - 1;
    });

    // Update global index
    index = units.length + 1;
  }

  function rewriteIndexedId(str, newIndex) {
    return str
      .replace(
        /ride_dest_address_attributes_\d+_/g,
        `ride_dest_address_attributes_${newIndex}_`,
      )
      .replace(/stop_\d+_/g, `stop_${newIndex}_`);
  }

  // Auto-generate duplicated stops from controller
  if (
    typeof gon !== "undefined" &&
    gon.duplicated_stops &&
    gon.duplicated_stops.length > 0
  ) {
    gon.duplicated_stops.forEach((stopData) => {
      addStopRow(stopData);
    });
  }
});