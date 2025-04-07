// Generates checkboxes for showing/hiding DataTable columns
const initiateCheckboxes = (table) => {
  const columnToggleContainer = document.getElementById('column-toggle-container');
  columnToggleContainer.innerHTML = '';

  table.columns().every((index) => {
    if (index >= 2) {
      columnToggleContainer.innerHTML += `
        <div class="form-check form-switch form-check-inline">
          <input 
            type="checkbox" 
            class="form-check-input" 
            id="col-${index}" 
            ${table.column(index).visible() ? 'checked' : ''}>
          <label class="form-check-label ms-1" for="col-${index}">
            ${table.column(index).header().textContent}
          </label>
        </div>`;
    }
  });

  // Listen for checkbox toggle changes
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

  // Updates footer with relevant stats
  const updateFooter = (index, dataTable, footerTH) => {
    const footerClass = footerTH.attr('class');
    const parseAmount = val => parseFloat(val.replace(/[\$,]/g, '')) || 0;

    const filteredData = dataTable
      .cells(null, index, { search: 'applied' })
      .render('display')
      .toArray()
      .filter(val => val && val.trim() !== '');

    if (footerClass.includes('stat-total')) {
        const total = filteredData.reduce((sum, val) => sum + parseAmount(val), 0);
        footerTH.html(`${total.toFixed(2)}`);

    } else if (footerClass.includes('stat-total-money')) {
        const total = filteredData.reduce((sum, val) => sum + parseAmount(val), 0);
        footerTH.html(`$${total.toFixed(2)}`);

    } else if (footerClass.includes('stat-percentage')) {
        const cityCounts = {};
        const total = filteredData.length;

        filteredData.forEach(val => {
            const cityMatch = val.match(/,\s*(\w+)\s*,/);
            const city = cityMatch ? cityMatch[1] : "Unknown";
            cityCounts[city] = (cityCounts[city] || 0) + 1;
        });

        const percentages = Object.entries(cityCounts)
            .map(([city, count]) => `${city}: ${(count / total * 100).toFixed(1)}%`)
            .join("<br>");

        footerTH.html(percentages);

    } else if (footerClass.includes('stat-count')) {
        footerTH.html(`${filteredData.length} entries`);
    }
  } 
  
  // Displays relevant data for rides table needed for forms
  const ridesRelevantStats = function() {
    const dataTable = this.api();
    
    dataTable.columns().every((index) => {
        const footerTH = $(dataTable.table().footer()).find('tr.column-summary th').eq(index);
        if (!footerTH.hasClass('ignore')) {
            updateFooter(index, dataTable, footerTH);
        }
    });
  }
  
  // Displays relevant data for passengers table needed for forms
  const passengersRelevantData = function() {
    const dataTable = this.api();
    
    dataTable.columns().every((index) => {
        const footerTH = $(dataTable.table().footer()).find('tr.column-summary th').eq(index);
        if (!footerTH.hasClass('ignore')) {
            updateFooter(index, dataTable, footerTH);
        }
    });
  }
  
  // Creates the Datatables
  const initiateDatatables = () => {
    const tables = [
      { selector: '#passengers-table', order: [[2, 'asc']], footerCallback: passengersRelevantData},
      { selector: '#rides-table', order: [[2, 'desc']], footerCallback: ridesRelevantStats}
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