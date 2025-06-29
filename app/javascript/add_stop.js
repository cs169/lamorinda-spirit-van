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

  // Get drivers data from gon
  let driversData = [];
  if (typeof gon !== 'undefined' && gon.drivers) {
    driversData = gon.drivers;
  }

  function populateDriverSelect(selectElement) {
    // Clear existing options except the first one
    selectElement.innerHTML = '<option value="">Select a Driver</option>';
    
    // Add driver options
    driversData.forEach(function(driver) {
      const option = document.createElement('option');
      option.value = driver.id;
      option.textContent = driver.name;
      selectElement.appendChild(option);
    });
  }

  addButton.addEventListener("click", function () {
    try {
      const html = template.innerHTML.replace(/__INDEX__/g, index);
      const wrapper = document.createElement("div");
      wrapper.innerHTML = html;

      if (wrapper.firstElementChild) {
        // Populate driver dropdown in the new stop
        const driverSelect = wrapper.querySelector('.driver-select');
        if (driverSelect && driversData.length > 0) {
          populateDriverSelect(driverSelect);
        }

        // Add the new stop card to the stops container
        stopsContainer.appendChild(wrapper.firstElementChild);
        
        index += 1;
        if (addressGrid) {
          addressGrid.dataset.lastIndex = index - 1;
        }
      }
    } catch (error) {
      console.error("Error adding stop:", error);
    }
  });

  deleteButton.addEventListener("click", function () {
    try {
      // Remove the last stop card if there's more than one stop
      if (stopsContainer.children.length > 1) {
        stopsContainer.removeChild(stopsContainer.lastElementChild);
        index -= 1;
        if (addressGrid) {
          addressGrid.dataset.lastIndex = index - 1;
        }
      }
    } catch (error) {
      console.error("Error deleting stop:", error);
    }
  });
});
