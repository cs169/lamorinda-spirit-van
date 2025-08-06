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
    const columnHeader = column.header().textContent.trim();

    // Special handling for Date column
    if (columnHeader === 'Date') {
      // Create date range inputs
      const $dateContainer = $('<div style="display: flex; flex-direction: column; gap: 2px;"></div>');
      
      // Get saved state for this table and column
      const tableId = table.table().node().id;
      const savedState = localStorage.getItem(`${tableId}_dateFilter`);
      let fromDateValue = '';
      let toDateValue = '';
      
      if (savedState) {
        try {
          const parsedState = JSON.parse(savedState);
          fromDateValue = parsedState.fromDate || '';
          toDateValue = parsedState.toDate || '';
        } catch (e) {
          console.log('Error parsing saved date filter state:', e);
        }
      }
      
      // From date input
      const $fromDate = $('<input type="date" placeholder="From date" title="From date"/>')
        .css({
          'width': '100%',
          'box-sizing': 'border-box',
          'margin': '0',
          'padding': '2px 4px',
          'font-size': '0.8rem'
        })
        .val(fromDateValue);
      
      // To date input  
      const $toDate = $('<input type="date" placeholder="To date" title="To date"/>')
        .css({
          'width': '100%',
          'box-sizing': 'border-box',
          'margin': '0',
          'padding': '2px 4px',
          'font-size': '0.8rem'
        })
        .val(toDateValue);

      $dateContainer.append($fromDate).append($toDate);
      $footerCell.append($dateContainer);

      // Custom filtering function for date range
      const filterByDateRange = () => {
        const fromDate = $fromDate.val();
        const toDate = $toDate.val();
        
        // Save the date filter state
        const dateFilterState = {
          fromDate: fromDate,
          toDate: toDate
        };
        localStorage.setItem(`${tableId}_dateFilter`, JSON.stringify(dateFilterState));
        
        // Remove any existing custom search for this column
        column.search('').draw(false);
        
        // Remove any existing date filters for this table
        $.fn.dataTable.ext.search = $.fn.dataTable.ext.search.filter(function(fn) {
          return fn.toString().indexOf(tableId) === -1;
        });
        
        // Apply custom filter only if we have date values
        if (fromDate || toDate) {
          $.fn.dataTable.ext.search.push(function(settings, data, dataIndex) {
            // Only apply to our specific table
            if (settings.nTable.id !== tableId) {
              return true;
            }
            
            const dateColumnIndex = column.index();
            const cellData = data[dateColumnIndex];
            
            // Extract date from the cell (it's in MM/DD/YYYY format)
            if (!cellData) return true;
            
            // Parse the displayed date (MM/DD/YYYY format)
            const dateParts = cellData.match(/(\d{1,2})\/(\d{1,2})\/(\d{4})/);
            if (!dateParts) return true;
            
            const cellDate = new Date(dateParts[3], dateParts[1] - 1, dateParts[2]); // Year, Month (0-based), Day
            
            // Check date range
            if (fromDate && toDate) {
              const from = new Date(fromDate);
              const to = new Date(toDate);
              return cellDate >= from && cellDate <= to;
            } else if (fromDate) {
              const from = new Date(fromDate);
              return cellDate >= from;
            } else if (toDate) {
              const to = new Date(toDate);
              return cellDate <= to;
            }
            
            return true;
          });
        }
        
        table.draw();
        updateFilterIndicator(table, '#' + table.table().node().id);
      };

      // Clear date range filter
      const clearDateRangeFilter = () => {
        // Remove our custom filter
        $.fn.dataTable.ext.search = $.fn.dataTable.ext.search.filter(function(fn) {
          return fn.toString().indexOf(tableId) === -1;
        });
        
        // Clear saved state
        localStorage.removeItem(`${tableId}_dateFilter`);
        
        $fromDate.val('');
        $toDate.val('');
        table.draw();
        updateFilterIndicator(table, '#' + table.table().node().id);
      };

      // Event handlers
      $fromDate.on('change', filterByDateRange);
      $toDate.on('change', filterByDateRange);
      
      // Clear button
      const $clearBtn = $('<button type="button" title="Clear date filter" style="width: 100%; margin-top: 2px; padding: 2px; font-size: 0.7rem; background: #f8f9fa; border: 1px solid #ddd; border-radius: 3px;">Clear</button>');
      $clearBtn.on('click', clearDateRangeFilter);
      $dateContainer.append($clearBtn);
      
      // Apply saved filter on page load
      if (fromDateValue || toDateValue) {
        filterByDateRange();
      }
      
    } else {
      // Regular text search for other columns
      const searchValue = column.search() || '';

      $('<input type="text"/>')
        .attr('placeholder', `${columnHeader}...`)
        .val(searchValue)
        .css({
          'width': '100%',
          'box-sizing': 'border-box',
          'margin': '0',
          'padding': '2px 4px',
          'font-size': '0.8rem'
        })
        .appendTo($footerCell)
        .on('keyup change clear', function () {
          if (column.search() !== this.value) {
            column.search(this.value).draw();
            // update filter indicator after table redraw
            updateFilterIndicator(table, '#' + table.table().node().id);
          }
        });
    }
  });
};

// Visual for when search has been applied
function updateFilterIndicator(table, tableSelector) {
  // Check if any column search is applied
  let columnFiltered = false;
  table.columns().every(function () {
    if (this.search() !== '') columnFiltered = true;
  });

  // Check if any custom date range filters are applied
  let dateRangeFiltered = false;
  const dateInputs = $(table.table().footer()).find('input[type="date"]');
  dateInputs.each(function() {
    if ($(this).val() !== '') dateRangeFiltered = true;
  });

  const indicatorDiv = document.querySelector(`${tableSelector}-filter-indicator`);
  if (columnFiltered || dateRangeFiltered) {
    indicatorDiv.innerHTML = `
      <div style="
        background: #ffe066;
        color: #8d5400;
        border: 2px solid #ffd43b;
        border-radius: 8px;
        font-size: 1.6rem;
        font-weight: bold;
        padding: 16px;
        margin-bottom: 10px;
        text-align: center;
        letter-spacing: 1px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.09);
      ">
        <span> Filter Active — Results Limited </span>
        <br>
        <span>Check the search bars below</span>
      </div>
    `;
  } else {
    indicatorDiv.innerHTML = '';
  }
}

  
// Creates the Datatables
const initiateDatatables = () => {
  const tables = [
    { selector: '#passengers-table', order: [[2, 'asc']]},
    { selector: '#rides-table', order: [[3, 'desc']]},
    { selector: '#shift-rides-table', order: [[5, 'asc']]}
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
      updateFilterIndicator(newTable, table.selector);

      // Rebuild searchbars on column reorder
      newTable.on('column-reorder', function () {
        initiateSearchbars(newTable);
      });
    }
  });
}

document.addEventListener('turbo:load', () => {
  if (document.querySelector('#passengers-table') || document.querySelector('#rides-table') 
    || document.querySelector('#shift-rides-table')) {
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
  ['#passengers-table', '#rides-table', '#shift-rides-table'].forEach(selector => {
    const tableElement = document.querySelector(selector);
    if (tableElement && $.fn.DataTable.isDataTable(tableElement)) {
      $(tableElement).DataTable().destroy();
    }
  });
});
