// Generates checkboxes for showing/hiding columns
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

// Generates search bars for searching each column
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

    // For "Date" column in Rides, we want a date range search
    // Caution: This code is heavily Ai-generated and complicated
    if (columnHeader === 'Date') {
      const $dateContainer = $('<div style="display: flex; flex-direction: column; gap: 2px;"></div>');

      const tableId = table.table().node().id;
      const savedState = localStorage.getItem(`${tableId}_dateFilter`);
      let fromDateValue = '';
      let toDateValue = '';

      if (savedState) {
        const parsedState = JSON.parse(savedState);
        fromDateValue = parsedState.fromDate || '';
        toDateValue = parsedState.toDate || '';
      }

      const $fromDate = $('<input type="date" placeholder="From date" title="From date"/>')
        .css({
          'width': '100%',
          'box-sizing': 'border-box',
          'margin': '0',
          'padding': '2px 4px',
          'font-size': '0.8rem'
        })
        .val(fromDateValue);

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

      // filtering function for date range
      const filterByDateRange = () => {
        const fromVal = $fromDate.val();
        const toVal = $toDate.val();

        // remove any existing date-filters for this table
        $.fn.dataTable.ext.search = $.fn.dataTable.ext.search
          .filter(fn => fn._tableId !== tableId);

        // save state
        localStorage.setItem(
          `${tableId}_dateFilter`,
          JSON.stringify({ fromDate: fromVal, toDate: toVal })
        );

        // only push a new filter if the user has actually selected a date
        if (fromVal || toVal) {
          const from = fromVal ? new Date(fromVal) : null;
          const to = toVal ? new Date(toVal) : null;

          // create & tag the callback
          const cb = function (settings, data) {
            // ignore other tables
            if (settings.nTable.id !== tableId) return true;

            const cell = data[column.index()] || '';
            const parts = cell.match(/(\d{1,2})\/(\d{1,2})\/(\d{4})/);
            if (!parts) return true;

            const [_, M, D, Y] = parts;
            const cd = new Date(Y, M - 1, D);

            if (from && to) return cd >= from && cd <= to;
            if (from) return cd >= from;
            if (to) return cd <= to;
            return true;
          };
          cb._tableId = tableId;

          $.fn.dataTable.ext.search.push(cb);
        }

        table.draw(false);
        updateFilterIndicator(table, `#${tableId}`);
      };

      const clearDateRangeFilter = () => {
        // strip out *all* callbacks tagged for this table
        $.fn.dataTable.ext.search = $.fn.dataTable.ext.search
          .filter(fn => fn._tableId !== tableId);

        // clear storage and inputs
        localStorage.removeItem(`${tableId}_dateFilter`);
        $fromDate.val('');
        $toDate.val('');

        // redraw to show everything again
        table.draw(false);
        updateFilterIndicator(table, `#${tableId}`);
      };

      $fromDate.on('change', filterByDateRange);
      $toDate.on('change', filterByDateRange);

      // Clear button
      const $clearBtn = $('<button type="button" title="Clear date filter" style="width: 100%; margin-top: 2px; padding: 2px; font-size: 0.7rem; background: #f8f9fa; border: 1px solid #ddd; border-radius: 3px;">Clear</button>');
      $clearBtn.on('click', clearDateRangeFilter);
      $dateContainer.append($clearBtn);

      if (fromDateValue || toDateValue) {
        filterByDateRange();
      }

    // Regular text search for other columns
    } else {
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
  dateInputs.each(function () {
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
    { selector: '#passengers-table', order: [[2, 'asc']] },
    { selector: '#rides-table', order: [[3, 'desc']] },
    { selector: '#shift-rides-table', order: [[5, 'asc']] }
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
            render: function (data, type, row, meta) {
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
