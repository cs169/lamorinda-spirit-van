// Generates checkboxes for showing/hiding DataTable columns
const initiateCheckboxes = (table) => {
    const columnToggleContainer = document.getElementById('column-toggle-container');
    columnToggleContainer.innerHTML = '';

    table.columns().every(function () {
      const index = this.index();
      const headerText = this.header().textContent.trim();
  
      // Only add checkbox if header text is not empty
      if (headerText) {
        columnToggleContainer.innerHTML += `
          <div class="form-check form-check-inline">
            <input type="checkbox" class="form-check-input" id="col-${index}" ${this.visible() ? 'checked' : ''}>
            <label class="form-check-label" for="col-${index}">${headerText}</label>
          </div>`;
      }
    });
  
    // on change event for checkboxes
    document.addEventListener('change', (event) => {
      if (event.target.matches('.form-check-input')) {
        const index = event.target.id.replace('col-', '');
        table.column(index).visible(event.target.checked);
      }
    });
  };
  
// Generates search bars for searching of each column of datatables
const initiateSearchbars = table => {
  // Clear existing search bars
  $(table.table().footer()).find('th').each(function () {
    $(this).empty();
  });
  
  // Create new search bars for each column with class 'text-filter'
  table.columns('.text-filter').every(function () {
    const column = this;
    const $footerCell = $(column.footer()).empty();

    // Use the saved search term (if any) for this column
    const searchValue = column.search() || '';

    $('<input type="text"/>')
      .attr('placeholder', `${column.header().textContent.trim()}...`)
      .val(searchValue)
      .css({
        'width':        '100%',
        'box-sizing':   'border-box',
        'margin':       '0',
        'padding':      '2px 4px',
        'font-size':    '0.8rem'
      })
      .appendTo($footerCell)
      .on('keyup change clear', function () {
        if (column.search() !== this.value) {
          column.search(this.value).draw();
        }
      });
  });
};
  
// Creates the Datatables
const initiateDatatables = () => {
  const tables = [
    { selector: '#passengers-table', order: [[15, 'desc']]},
    { selector: '#rides-table', order: [[3, 'desc']]}
  ];

  tables.forEach(table => {
    const tableElement = document.querySelector(table.selector);
    if (tableElement) {
      if ($.fn.DataTable.isDataTable(tableElement)) {
        $(table.selector).DataTable().destroy();
      }

      const newTable = $(tableElement).DataTable({
        colReorder: true,    
        stateSave: true,    
        autoWidth: false,
        paging: true,
        searching: true,
        ordering: true,
        pageLength: 10,
        order: table.order,
        dom: "<'row'<'col-md-6'l><'col-md-6'Bp>>" +
             "<'row'<'col-md-12'tr>>" +
             "<'row'<'col-md-6'i><'col-md-6'>>",
        buttons: [
           'excel', 'csv', 'print'
        ],
        columnDefs: [
          {
            targets: '_all',
            render: function(data, type, row, meta) {
              if (type === 'sort' || type === 'type') {
                // Only apply custom sorting if the cell has a data-sort attribute
                if (typeof data === 'string' && data.includes('data-sort=')) {
                  const match = data.match(/data-sort="(\d+)"/);
                  if (match) {
                    return parseInt(match[1]) || 0;
                  }
                }
              }
              return data;
            }
          }
        ]
      });
      initiateCheckboxes(newTable);
      initiateSearchbars(newTable);

      // Rebuild searchbars on column reorder
      newTable.on('column-reorder', function () {
        initiateSearchbars(newTable);
      });
    }
  });
}

document.addEventListener('turbo:load', () => {
  if (document.querySelector('#passengers-table') || document.querySelector('#rides-table')) {
    initiateDatatables();
  }

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

// For preventing DataTable from being initialized multiple times when user clicks browser's back arrow
document.addEventListener('turbo:before-cache', () => {
  // Destroy all datatables before caching
  ['#passengers-table', '#rides-table'].forEach(selector => {
    const tableElement = document.querySelector(selector);
    if (tableElement && $.fn.DataTable.isDataTable(tableElement)) {
      $(tableElement).DataTable().destroy();
    }
  });
});
