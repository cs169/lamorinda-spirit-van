// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";
import "controllers";

function selectPassenger(name, phone, address, city) {
  document.getElementById("passenger_name").value = name;
  document.getElementById("passenger_phone").value = phone;
  document.getElementById("passenger_address").value = address;
  document.getElementById("passenger_city").value = city;
}

// Generate checkboxes for showing/hiding DataTable columns
const initiateCheckboxes = (table) => {
    const columnToggleContainer = document.getElementById('column-toggle-container');
    columnToggleContainer.innerHTML = '';

    table.columns().every(function (index) {
      if (index < table.columns().count() - 2) {
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

document.addEventListener('turbo:load', () => {
  const tableElement = document.querySelector('#passengers-table');
  if (tableElement) {
    if ($.fn.DataTable.isDataTable('#passengers-table')) {
      $('#passengers-table').DataTable().destroy();
    }
    
    const passengerTable = $('#passengers-table').DataTable({
      paging: true,
      searching: true,
      ordering: true,
      pageLength: 10,  
      order: [[0, 'asc']],
      language: {
        searchPlaceholder: "Search..."
      },

      buttons: [
        {
          extend: 'csv',
          text: 'Export CSV',
          className: 'btn btn-sm btn-outline-secondary'
        },
        {
          extend: 'excel',
          text: 'Export Excel',
          className: 'btn btn-sm btn-outline-secondary'
        },
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
        {
          extend: 'print',
          text: 'Print',
          className: 'btn btn-sm btn-outline-secondary'
        }
      ],
      scrollX: true,
      dom: "<'row'<'col-md-6'l><'col-md-6'Bf>>" + 
      "<'row'<'col-md-12'tr>>" + 
      "<'row'<'col-md-6'i><'col-md-6'p>>",
    });
    
    initiateCheckboxes(passengerTable);
  }

  // Make table rows clickable (except for links/buttons inside them)
  document.querySelectorAll('.clickable-row').forEach(row => {
    row.addEventListener('click', function(event) {
      if (event.target.closest('a') || event.target.closest('button')) {
        return;
      }
      window.location = this.dataset.href;
    });
  });

  // Flash message auto-hide after 5 seconds
  let flashMessage = document.querySelector(".alert");
  if (flashMessage) {
    setTimeout(() => {
      flashMessage.style.transition = "opacity 2s ease-in-out";
      flashMessage.style.opacity = "0";
      setTimeout(() => flashMessage.remove(), 2000); 
    }, 5000); 
  }
});

window.selectPassenger = selectPassenger;
