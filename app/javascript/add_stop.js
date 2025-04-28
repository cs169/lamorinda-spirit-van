document.addEventListener("turbo:load", function () {
  const addButton = document.getElementById("add-stop-button");
  const deleteButton = document.getElementById("delete-stop-button");
  const grid = document.getElementById("address-grid");
  const template = document.getElementById("destination-template");

  let stopIndex = 2;

  addButton.addEventListener("click", function () {
    const html = template.innerHTML.replace(/__INDEX__/g, stopIndex);
    const wrapper = document.createElement("div");
    wrapper.innerHTML = html;

    // Add spacer and new stop
    const spacer = document.createElement("div");
    spacer.className = "col-md-1";
    grid.appendChild(wrapper.firstElementChild);
    grid.appendChild(spacer);

    stopIndex++;
  });

  deleteButton.addEventListener("click", function () {
    // Remove the last spacer + stop (2 elements)
    if (grid.children.length > 3) {
      grid.removeChild(grid.lastElementChild);
      grid.removeChild(grid.lastElementChild);
      stopIndex--;
    }
  });
});