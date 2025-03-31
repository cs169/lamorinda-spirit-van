// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Generate checkboxes for showing/hiding DataTable columns
const initiateCheckboxes = (table) => {
  const columnToggleContainer = document.getElementById('column-toggle-container');
  columnToggleContainer.innerHTML = '';

  table.columns().every((index) => {
    if (index >= 2) {
      columnToggleContainer.innerHTML += `
        <div class="form-check form-check-inline">
          <input type="checkbox" class="form-check-input" id="col-${index}" ${table.column(index).visible() ? 'checked' : ''}>
          <label class="form-check-label" for="col-${index}">${table.column(index).header().textContent}</label>
        </div>`;
    }
  });

  // Event delegation for checkboxes
  document.addEventListener('change', (event) => {
    if (event.target.matches('.form-check-input')) {
      const index = event.target.id.replace('col-', '');
      table.column(index).visible(event.target.checked);
    }
  });
};

document.addEventListener('DOMContentLoaded', () => {

  const tables = [
    { selector: '#passengers-table', order: [[2, 'asc']], searchPlaceholder: "Search passengers..." },
    { selector: '#rides-table', order: [[2, 'desc']], searchPlaceholder: "Search rides..." }
  ];

  tables.forEach(table => {
    const tableElement = document.querySelector(table.selector);
    if (tableElement) {
      if ($.fn.DataTable.isDataTable(table.selector)) {
        $(table.selector).DataTable().destroy();
      }

      const newTable = $(table.selector).DataTable({
        paging: true,
        searching: true,
        ordering: true,
        pageLength: 10,
        order: table.order,
        language: {
          searchPlaceholder: table.searchPlaceholder
        },
        scrollX: true,

        buttons: [
          {
            extend: 'pdf',
            title: 'RideData',
            messageTop: 'List of rides',
            orientation: 'landscape',
            pageSize: 'A4',
            exportOptions: {
              columns: ':visible' // Export only visible columns
            }
          },
        ],
        dom: "<'row'<'col-md-6'l><'col-md-6'Bf>>" +
          "<'row'<'col-md-12'tr>>" +
          "<'row'<'col-md-6'i><'col-md-6'p>>",
      });
      initiateCheckboxes(newTable);
    }
  });

  // Flash message auto-hide after 5 seconds
  const flashMessage = document.querySelector(".alert");
  if (flashMessage) {
    setTimeout(() => {
      flashMessage.style.transition = "opacity 2s ease-in-out";
      flashMessage.style.opacity = "0";
      setTimeout(() => flashMessage.remove(), 2000);
    }, 5000);
  }
});
