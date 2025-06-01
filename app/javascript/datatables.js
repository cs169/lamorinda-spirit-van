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
    table.columns('.text-filter').every(function () {
      const column = this;
      const $footerCell = $(column.footer()).empty();
      $('<input type="text"/>')
        .attr('placeholder', `${column.header().textContent.trim()}...`)
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
      { selector: '#passengers-table', order: [[15, 'desc']], footerCallback: passengersRelevantData},
      { selector: '#rides-table', order: [[3, 'desc']], footerCallback: ridesRelevantStats}
    ];
  
    tables.forEach(table => {
      const tableElement = document.querySelector(table.selector);
      if (tableElement) {
        if ($.fn.DataTable.isDataTable(table.selector)) {
          $(table.selector).DataTable().destroy();
        }
        const newTable = $(table.selector).DataTable({
          colReorder: true,    
          stateSave: true,    
          autoWidth: false,
          paging: true,
          searching: true,
          ordering: true,
          pageLength: 10,
          order: table.order,
          dom: "<'row'<'col-md-6'l><'col-md-6'>>" +
            "<'row'<'col-md-12'tr>>" +
            "<'row'<'col-md-6'i><'col-md-6'p>>",
        });
        initiateCheckboxes(newTable);
        initiateSearchbars(newTable);
      }
    });
  }
  
  document.addEventListener('turbo:load', () => {
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