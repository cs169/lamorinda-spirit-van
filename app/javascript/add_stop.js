document.addEventListener("DOMContentLoaded", function () {
  const addButton = document.getElementById("add-stop-button");
  const deleteButton = document.getElementById("delete-stop-button");

  const dest = document.getElementById("destination-form");
  const space = document.getElementById("col-space")
  const grid = document.getElementById("address-grid");
  let stopIndex = 2;

  addButton.addEventListener("click", function () {

    console.log(grid.children);

    const cloneDest = dest.cloneNode(true);
    const cloneSpace = space.cloneNode(true);

    grid.appendChild(cloneDest);
    grid.appendChild(cloneSpace);
  });

  deleteButton.addEventListener("click", function () {
    // Removes space and dest clone
    console.log(grid.children)
    if (grid.children.length > 3) {
      grid.removeChild(grid.lastElementChild);
      grid.removeChild(grid.lastElementChild);
    }
  });






});
