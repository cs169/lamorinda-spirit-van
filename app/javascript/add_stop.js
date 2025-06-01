document.addEventListener("turbo:load", function () {
  const addButton = document.getElementById("add-stop-button");
  const deleteButton = document.getElementById("delete-stop-button");
  const grid = document.getElementById("address-grid");
  const template = document.getElementById("destination-template");

  let index = parseInt(grid.dataset.lastIndex, 10) + 1 || 2;

  addButton.addEventListener("click", function () {
    const html = template.innerHTML.replace(/__INDEX__/g, index);
    const wrapper = document.createElement("div");
    wrapper.innerHTML = html;

    const spacer = document.createElement("div");
    spacer.className = "col-md-1";

    grid.appendChild(wrapper.firstElementChild);
    grid.appendChild(spacer);

    index += 1;
    grid.dataset.lastIndex = index - 1; 
  });

  deleteButton.addEventListener("click", function () {
    // Must remove the spacer and the stop (2 elements)
    // 4 turned out to be the min number to prevent issues with rides new and edit (don't know why)
    if (grid.children.length > 4) {
      grid.removeChild(grid.lastElementChild);
      grid.removeChild(grid.lastElementChild);
      index -= 1;
      grid.dataset.lastIndex = index - 1;
    }
  });
});
