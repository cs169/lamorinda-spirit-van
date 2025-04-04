// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Generates checkboxes for showing/hiding DataTable columns
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

// Generates search bars for searching of each column of datatables
const initiateSearchbars = (table) => {
  table.columns('.text-filter').every(function () {
    const column = this;
  
    // Create search input element and append it to the table
    $('<input type="text"/>')
      .attr('placeholder', `Search ${column.header().textContent.trim()}...`)
      .appendTo(column.footer())
      .on('keyup change clear', function () {
        if (column.search() !== this.value) {
          column.search(this.value).draw();
        }
      });
  });
}

// Displays relevant data for rides table needed for forms
const ridesRelevantData = function(row, data, start, end, display) {
  const api = this.api();
  const parseAmount = val => parseFloat(val.replace(/[\$,]/g, '')) || 0;

  api.columns().every(function (index) {
    const column = this;
    const footerCell = $(api.table().footer()).find('tr.column-summary th').eq(index);

    const filteredData = api
      .cells(null, index, { search: 'applied' })
      .render('display')
      .toArray()
      .filter(val => val && val.trim() !== '');

    // Amount Paid col
    if (index === 10) {
      const total = filteredData.reduce((sum, val) => sum + parseAmount(val), 0);
      footerCell.html(`$${total.toFixed(2)}`);

    // Origin or Destination cols
    } else if (index === 6 || index === 7) {
      const cityCounts = {};
      const total = filteredData.length;

      filteredData.forEach(val => {
        // Extract just the city from a full address
        const cityMatch = val.match(/,\s*(\w+)\s*,/);
        const city = cityMatch ? cityMatch[1] : "Unknown";
        cityCounts[city] = (cityCounts[city] || 0) + 1;
      });

      const percentages = Object.entries(cityCounts)
        .map(([city, count]) => `${city}: ${(count / total * 100).toFixed(1)}%`)
        .join("<br>");

      footerCell.html(percentages);

    // Other columns: count entries
    } else {
      footerCell.html(`${filteredData.length} entries`);
    }
  })
}

// Displays relevant data for passengers table needed for forms
const passengersRelevantData = function(row, data, start, end, display) {
  const api = this.api();

  api.columns().every(function (index) {
    const column = this;
    const footerCell = $(api.table().footer()).find('tr.column-summary th').eq(index);

    const filteredData = api
      .cells(null, index, { search: 'applied' })
      .render('display')
      .toArray()
      .filter(val => val && val.trim() !== '');
    
    // address column: percentage of each city
    if (index === 3) {
      const cityCounts = {};
      const total = filteredData.length;

      filteredData.forEach(val => {
        // Extract just the city from a full address
        const cityMatch = val.match(/,\s*(\w+)\s*,/);
        const city = cityMatch ? cityMatch[1] : "Unknown";
        cityCounts[city] = (cityCounts[city] || 0) + 1;
      });

      const percentages = Object.entries(cityCounts)
        .map(([city, count]) => `${city}: ${(count / total * 100).toFixed(1)}%`)
        .join("<br>");

      footerCell.html(percentages);

    // Other columns: count entries
    } else {
      footerCell.html(`${filteredData.length} entries`);
    }
  })
}

// Creates the Datatables
const initiateDatatables = () => {
  const tables = [
    { selector: '#passengers-table', order: [[2, 'asc']], footerCallback: passengersRelevantData},
    { selector: '#rides-table', order: [[2, 'desc']], footerCallback: ridesRelevantData}
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
        scrollX: true,
        footerCallback: table.footerCallback,
        dom: "<'row'<'col-md-6'l><'col-md-6'>>" +
          "<'row'<'col-md-12'tr>>" +
          "<'row'<'col-md-6'i><'col-md-6'p>>",
      });
      initiateCheckboxes(newTable);
      initiateSearchbars(newTable);
    }
  });
}

document.addEventListener('DOMContentLoaded', () => {
  initiateDatatables();

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
