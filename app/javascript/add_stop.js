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

  function populateDriverSelect(selectElement) {
    // Clear existing options except the first one
    selectElement.innerHTML = '<option value="">Select a Driver</option>';

    // Add driver options
    driversData.forEach(function (driver) {
      const option = document.createElement("option");
      option.value = driver.id;
      option.textContent = driver.name;
      selectElement.appendChild(option);
    });
  }

  stopsContainer.addEventListener("click", function (e) {
    const btn = e.target.closest(".add-stop-button");
    if (!btn) return;

    try {
      const stopUnit = btn.closest(".col-md-12.mb-4");
      if (!stopUnit) return;

      const html = template.innerHTML.replace(/__INDEX__/g, index);
      const wrapper = document.createElement("div");
      wrapper.innerHTML = html;

      const newStop = wrapper.querySelector(".col-md-12.mb-4");
      if (!newStop) return;

      // Populate driver dropdown in the new stop
      const driverSelect = newStop.querySelector(".driver-select");
      if (driverSelect && driversData.length > 0) {
        populateDriverSelect(driverSelect);
      }

      stopUnit.insertAdjacentElement("afterend", newStop);

      reindexStops();

      if (addressGrid) addressGrid.dataset.lastIndex = index - 1;
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

  // Add Button Event
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
});
