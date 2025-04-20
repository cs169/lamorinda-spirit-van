document.addEventListener("DOMContentLoaded", function () {
  const addButton = document.getElementById("add-stop-button");
  const deleteButton = document.getElementById("delete-stop-button");
  const addDestContainer = document.getElementById("add-dest-container");
  const dest = document.getElementById("destination");
  const space = document.getElementById("col-space")

  addButton.addEventListener("click", function () {
    const cloneDest = dest.cloneNode(true);
    const cloneSpace = space.cloneNode(true);
    addDestContainer.appendChild(cloneDest);
    addDestContainer.appendChild(cloneSpace);
  });

  deleteButton.addEventListener("click", function () {
    // Removes space and dest clone
    if (addDestContainer.children.length >= 2) {
      addDestContainer.removeChild(addDestContainer.lastElementChild);
      addDestContainer.removeChild(addDestContainer.lastElementChild);
    }
  });






});
