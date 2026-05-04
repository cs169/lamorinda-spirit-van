// Generates checkboxes for showing/hiding columns
const initiateCheckboxes = (table) => {
  const columnToggleContainer = document.getElementById(
    "column-toggle-container",
  );
  columnToggleContainer.innerHTML = "";

  table.columns().every(function () {
    const index = this.index();
    const headerText = this.header().textContent.trim();

    // Only add checkbox if header text is not empty
    if (headerText) {
      columnToggleContainer.innerHTML += `
          <div class="form-check form-check-inline">
            <input type="checkbox" class="form-check-input" id="col-${index}" ${this.visible() ? "checked" : ""}>
            <label class="form-check-label" for="col-${index}">${headerText}</label>
          </div>`;
    }
  });

  // on change event for checkboxes
  document.addEventListener("change", (event) => {
    if (event.target.matches(".form-check-input")) {
      const index = event.target.id.replace("col-", "");
      table.column(index).visible(event.target.checked);
    }
  });
};

// this parses as UTC, while new Date(y, m-1, d) is local midnight.
// In PDT, "2025-08-08" becomes 2025-08-08T00:00:00.000Z → 5pm on 8/7 local,
// so <= to fails for the selected “to” day.
// Heavily AI generated
const parseYMDLocal = (s) => {
  if (!s) return null;
  const [Y, M, D] = s.split("-").map(Number);
  return new Date(Y, M - 1, D);
};
// to fix parseYMDLocal
const startOfDay = (d) =>
  new Date(d.getFullYear(), d.getMonth(), d.getDate(), 0, 0, 0, 0);
const endOfDay = (d) =>
  new Date(d.getFullYear(), d.getMonth(), d.getDate(), 23, 59, 59, 999);

const loadDateState = (tableId) => {
  try {
    return (
      JSON.parse(localStorage.getItem(`${tableId}_dateFilter`)) || {
        fromDate: "",
        toDate: "",
      }
    );
  } catch {
    return { fromDate: "", toDate: "" };
  }
};

const saveDateState = (tableId, state) =>
  localStorage.setItem(`${tableId}_dateFilter`, JSON.stringify(state));

const removeDateFiltersFor = (tableId) => {
  $.fn.dataTable.ext.search = $.fn.dataTable.ext.search.filter(
    (fn) => fn._tableId !== tableId,
  );
};

// Heavily AI generated
const buildDateFilter = (tableId, colIndex, fromVal, toVal) => {
  const from = fromVal ? startOfDay(parseYMDLocal(fromVal)) : null;
  const to = toVal ? endOfDay(parseYMDLocal(toVal)) : null;

  const cb = function (settings, data) {
    if (settings.nTable.id !== tableId) return true;

    const cell = data[colIndex] || "";
    const match = cell.match(/(\d{1,2})\/(\d{1,2})\/(\d{4})/);
    if (!match) return true;

    const [, M, D, Y] = match;
    const cd = new Date(Y, M - 1, D); // local midnight

    if (from && to) return cd >= from && cd <= to;
    if (from) return cd >= from;
    if (to) return cd <= to;
    return true;
  };

  cb._tableId = tableId; // tag so we can remove later
  return cb;
};

// CSS for textInput and dateInput
const INPUT_CSS = {
  width: "100%",
  boxSizing: "border-box",
  margin: 0,
  padding: "2px 4px",
  fontSize: "0.8rem",
};

const textInput = (placeholder, value = "") =>
  $('<input type="text"/>')
    .attr("placeholder", placeholder)
    .val(value)
    .css(INPUT_CSS);

const dateInput = (value = "") =>
  $('<input type="date" title="Date"/>').val(value).css(INPUT_CSS);

// Creates search bars for date column and every other column
// Heavily AI generated
const initiateSearchbars = (table) => {
  // clear footer cells
  $(table.table().footer()).find("th").empty();

  table.columns(".text-filter").every(function () {
    const column = this;
    const $cell = $(column.footer()).empty();
    const header = column.header().textContent.trim();
    const tableId = table.table().node().id;

    // Date column => range filter
    if (header === "Date") {
      const { fromDate, toDate } = loadDateState(tableId);

      const $wrap = $(
        '<div style="display:flex;flex-direction:column;gap:2px;"></div>',
      );
      const $from = dateInput(fromDate);
      const $to = dateInput(toDate);
      $wrap.append($from, $to);

      const redraw = () => {
        table.draw(false);
        updateFilterIndicator(table, `#${tableId}`);
      };

      const applyDateFilter = () => {
        removeDateFiltersFor(tableId);
        const fromVal = $from.val();
        const toVal = $to.val();

        saveDateState(tableId, { fromDate: fromVal, toDate: toVal });

        if (fromVal || toVal) {
          $.fn.dataTable.ext.search.push(
            buildDateFilter(tableId, column.index(), fromVal, toVal),
          );
        }
        redraw();
      };

      const clearDateFilter = () => {
        removeDateFiltersFor(tableId);
        saveDateState(tableId, { fromDate: "", toDate: "" });
        $from.val("");
        $to.val("");
        redraw();
      };

      $from.on("change", applyDateFilter);
      $to.on("change", applyDateFilter);

      const $clearBtn = $(
        '<button type="button" title="Clear date filter" ' +
          'style="width:100%;margin-top:2px;padding:2px;font-size:0.7rem;' +
          'background:#f8f9fa;border:1px solid #ddd;border-radius:3px;">Clear</button>',
      ).on("click", clearDateFilter);

      $cell.append($wrap, $clearBtn);

      // re-apply on load if state exists
      if (fromDate || toDate) applyDateFilter();
    } else {
      // Plain text filter for all other columns
      const initial = column.search() || "";
      const $input = textInput(`${header}...`, initial).on(
        "input change",
        function () {
          if (column.search() !== this.value) {
            column.search(this.value).draw();
            updateFilterIndicator(table, `#${tableId}`);
          }
        },
      );

      $cell.append($input);
    }
  });
};

// Server-side variant of initiateSearchbars for the rides table.
// Date range: saves to localStorage and calls draw() — the ajax.data callback
// encodes the stored range into column 1's search value on each request.
// Text filters: identical to client-side; DataTables includes column search
// values automatically in every server-side AJAX request.
const initiateRidesSearchbars = (table) => {
  $(table.table().footer()).find("th").empty();

  table.columns(".text-filter").every(function () {
    const column = this;
    const $cell = $(column.footer()).empty();
    const header = column.header().textContent.trim();
    const tableId = table.table().node().id;

    if (header === "Date") {
      const { fromDate, toDate } = loadDateState(tableId);

      const $wrap = $(
        '<div style="display:flex;flex-direction:column;gap:2px;"></div>',
      );
      const $from = dateInput(fromDate);
      const $to = dateInput(toDate);
      $wrap.append($from, $to);

      const applyDateFilter = () => {
        saveDateState(tableId, { fromDate: $from.val(), toDate: $to.val() });
        table.draw();
        updateFilterIndicator(table, `#${tableId}`);
      };

      const clearDateFilter = () => {
        saveDateState(tableId, { fromDate: "", toDate: "" });
        $from.val("");
        $to.val("");
        table.draw();
        updateFilterIndicator(table, `#${tableId}`);
      };

      $from.on("change", applyDateFilter);
      $to.on("change", applyDateFilter);

      const $clearBtn = $(
        '<button type="button" title="Clear date filter" ' +
          'style="width:100%;margin-top:2px;padding:2px;font-size:0.7rem;' +
          'background:#f8f9fa;border:1px solid #ddd;border-radius:3px;">Clear</button>',
      ).on("click", clearDateFilter);

      $cell.append($wrap, $clearBtn);

      // Re-apply persisted date range on page load
      if (fromDate || toDate) table.draw();
    } else {
      const initial = column.search() || "";
      const $input = textInput(`${header}...`, initial).on(
        "input change",
        function () {
          if (column.search() !== this.value) {
            column.search(this.value).draw();
            updateFilterIndicator(table, `#${tableId}`);
          }
        },
      );
      $cell.append($input);
    }
  });
};

// Server-side variant of initiateSearchbars for the passengers table.
// Birthday range: saves to localStorage and calls draw() — the ajax.data callback
// encodes the stored range into column 9's search value on each request.
const initiatePassengersSearchbars = (table) => {
  $(table.table().footer()).find("th").empty();

  table.columns(".text-filter").every(function () {
    const column = this;
    const $cell = $(column.footer()).empty();
    const header = column.header().textContent.trim();
    const tableId = table.table().node().id;

    if (header === "Birthday") {
      const { fromDate, toDate } = loadDateState(`${tableId}_birthday`);

      const $wrap = $(
        '<div style="display:flex;flex-direction:column;gap:2px;"></div>',
      );
      const $from = dateInput(fromDate);
      const $to = dateInput(toDate);
      $wrap.append($from, $to);

      const applyBirthdayFilter = () => {
        saveDateState(`${tableId}_birthday`, { fromDate: $from.val(), toDate: $to.val() });
        table.draw();
        updateFilterIndicator(table, `#${tableId}`);
      };

      const clearBirthdayFilter = () => {
        saveDateState(`${tableId}_birthday`, { fromDate: "", toDate: "" });
        $from.val("");
        $to.val("");
        table.draw();
        updateFilterIndicator(table, `#${tableId}`);
      };

      $from.on("change", applyBirthdayFilter);
      $to.on("change", applyBirthdayFilter);

      const $clearBtn = $(
        '<button type="button" title="Clear birthday filter" ' +
          'style="width:100%;margin-top:2px;padding:2px;font-size:0.7rem;' +
          'background:#f8f9fa;border:1px solid #ddd;border-radius:3px;">Clear</button>',
      ).on("click", clearBirthdayFilter);

      $cell.append($wrap, $clearBtn);

      if (fromDate || toDate) table.draw();
    } else {
      const initial = column.search() || "";
      const $input = textInput(`${header}...`, initial).on(
        "input change",
        function () {
          if (column.search() !== this.value) {
            column.search(this.value).draw();
            updateFilterIndicator(table, `#${tableId}`);
          }
        },
      );
      $cell.append($input);
    }
  });
};

// Visual for when search has been applied
function updateFilterIndicator(table, tableSelector) {
  // Check if any column search is applied
  let columnFiltered = false;
  table.columns().every(function () {
    if (this.search() !== "") columnFiltered = true;
  });

  // Check if any custom date range filters are applied
  let dateRangeFiltered = false;
  const dateInputs = $(table.table().footer()).find('input[type="date"]');
  dateInputs.each(function () {
    if ($(this).val() !== "") dateRangeFiltered = true;
  });

  const indicatorDiv = document.querySelector(
    `${tableSelector}-filter-indicator`,
  );
  if (!indicatorDiv) return;
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
    indicatorDiv.innerHTML = "";
  }
}

// Column definitions for the passengers table (server-side processing).
const PASSENGERS_COLUMNS = [
  { orderable: false, searchable: false }, // 0  actions
  { orderable: true,  searchable: true  }, // 1  last name
  { orderable: true,  searchable: true  }, // 2  first name
  { orderable: false, searchable: false }, // 3  address (computed, not filterable)
  { orderable: true,  searchable: true  }, // 4  street
  { orderable: true,  searchable: true  }, // 5  city
  { orderable: true,  searchable: true  }, // 6  zip
  { orderable: true,  searchable: true  }, // 7  phone
  { orderable: true,  searchable: true  }, // 8  alt phone
  { orderable: true,  searchable: true  }, // 9  birthday (date range)
  { orderable: true,  searchable: false }, // 10 race (integer, not filterable)
  { orderable: true,  searchable: false }, // 11 hispanic
  { orderable: true,  searchable: false }, // 12 wheelchair
  { orderable: true,  searchable: false }, // 13 low income
  { orderable: true,  searchable: false }, // 14 disabled
  { orderable: true,  searchable: false }, // 15 caregiver
  { orderable: true,  searchable: true  }, // 16 notes
  { orderable: true,  searchable: true  }, // 17 email
  { orderable: true,  searchable: false }, // 18 date registered
  { orderable: true,  searchable: true  }, // 19 audit
  { orderable: true,  searchable: false }, // 20 lmv member
  { orderable: true,  searchable: true  }, // 21 mail updates
  { orderable: true,  searchable: true  }, // 22 requested newsletter
];

// Column definitions for the rides table (server-side processing).
// Columns spanning linked rides (drivers, vans, stops, destinations) are
// non-orderable because they cannot be sorted at the DB level.
const RIDES_COLUMNS = [
  { orderable: false, searchable: false }, // 0  actions
  { orderable: true,  searchable: true  }, // 1  date
  { orderable: true,  searchable: true  }, // 2  driver(s)
  { orderable: true,  searchable: true  }, // 3  van(s)
  { orderable: true,  searchable: true  }, // 4  last name
  { orderable: true,  searchable: true  }, // 5  first name
  { orderable: false, searchable: false }, // 6  stops info
  { orderable: true,  searchable: true  }, // 7  origin
  { orderable: true,  searchable: false }, // 8  appt. time
  { orderable: false, searchable: false }, // 9  destination(s)
  { orderable: true,  searchable: true  }, // 10 ride type
  { orderable: true,  searchable: false }, // 11 wheelchair
  { orderable: true,  searchable: false }, // 12 disabled
  { orderable: true,  searchable: false }, // 13 needs caregiver
  { orderable: true,  searchable: true  }, // 14 fare type
  { orderable: true,  searchable: false }, // 15 fare amount
  { orderable: true,  searchable: true  }, // 16 notes to driver
  { orderable: true,  searchable: true  }, // 17 notes
  { orderable: true,  searchable: false }, // 18 hours
  { orderable: true,  searchable: false }, // 19 amount paid
  { orderable: true,  searchable: true  }, // 20 status
];

// Creates the Datatables
const initiateDatatables = () => {
  // ── Non-server-side tables ─────────────────────────────────────────────────
  const tables = [
    { selector: "#shift-rides-table", order: [[5, "asc"]] },
  ];

  tables.forEach((table) => {
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
        dom:
          "<'row'<'col-md-6'l><'col-md-6'Bp>>" +
          "<'row'<'col-md-12'tr>>" +
          "<'row'<'col-md-6'i><'col-md-6'>>",
        buttons: ["excel", "csv", "print"],
      });

      initiateCheckboxes(newTable);
      initiateSearchbars(newTable);
      updateFilterIndicator(newTable, table.selector);

      newTable.on("column-reorder", function () {
        initiateSearchbars(newTable);
      });
    }
  });

  // ── Passengers table — server-side processing ─────────────────────────────
  const passengersElement = document.querySelector("#passengers-table");
  if (passengersElement) {
    if ($.fn.DataTable.isDataTable(passengersElement)) {
      $(passengersElement).DataTable().destroy();
    }

    const passengersTable = $(passengersElement).DataTable({
      serverSide: true,
      processing: true,
      autoWidth: false,
      pageLength: 25,
      order: [[2, "asc"]],
      columns: PASSENGERS_COLUMNS,
      ajax: {
        url: "/passengers.json",
        type: "GET",
        data: function (d) {
          const state = loadDateState("passengers-table_birthday");
          if (state.fromDate || state.toDate) {
            d.columns[9].search.value = `${state.fromDate}|${state.toDate}`;
          }
          return d;
        },
      },
      dom:
        "<'row'<'col-md-6'l><'col-md-6'Bp>>" +
        "<'row'<'col-md-12'tr>>" +
        "<'row'<'col-md-6'i><'col-md-6'>>",
      buttons: [
        {
          extend: "excel",
          text: "Excel",
          action: function (e, dt, button, config) {
            exportAllData(dt, "excel", this, e, button, config);
          }
        },
        {
          extend: "csv",
          text: "CSV",
          action: function (e, dt, button, config) {
            exportAllData(dt, "csv", this, e, button, config);
          }
        },
        "print"
      ],
    });

    // Hide Street, City, Zip columns (indices 4, 5, 6) by default
    [4, 5, 6].forEach((idx) => passengersTable.column(idx).visible(false));

    initiateCheckboxes(passengersTable);
    initiatePassengersSearchbars(passengersTable);
    updateFilterIndicator(passengersTable, "#passengers-table");
  }

  // ── Rides table — server-side processing ──────────────────────────────────
  // Page loads instantly with an empty table; DataTables fetches only the
  // current page via AJAX on every load/sort/filter/paginate action.
  const ridesElement = document.querySelector("#rides-table");
  if (ridesElement) {
    if ($.fn.DataTable.isDataTable(ridesElement)) {
      $(ridesElement).DataTable().destroy();
    }

    const ridesTable = $(ridesElement).DataTable({
      serverSide: true,
      processing: true,
      autoWidth: false,
      pageLength: 25,
      order: [[1, "desc"]],
      columns: RIDES_COLUMNS,
      ajax: {
        url: "/rides.json",
        type: "GET",
        // Encode the date range into column 1's search value as "from|to"
        // before each request so the server can apply it as a SQL WHERE clause.
        data: function (d) {
          const state = loadDateState("rides-table");
          if (state.fromDate || state.toDate) {
            d.columns[1].search.value = `${state.fromDate}|${state.toDate}`;
          }
          return d;
        },
      },
      dom:
        "<'row'<'col-md-6'l><'col-md-6'Bp>>" +
        "<'row'<'col-md-12'tr>>" +
        "<'row'<'col-md-6'i><'col-md-6'>>",
      buttons: [
        {
          extend: "excel",
          text: "Excel",
          action: function (e, dt, button, config) {
            exportAllData(dt, "excel", this, e, button, config);
          }
        },
        {
          extend: "csv",
          text: "CSV",
          action: function (e, dt, button, config) {
            exportAllData(dt, "csv", this, e, button, config);
          }
        },
        "print"
      ],
    });

    initiateCheckboxes(ridesTable);
    initiateRidesSearchbars(ridesTable);
    updateFilterIndicator(ridesTable, "#rides-table");
  }
};

// Usage: Rides Index (Later: Passengers Index) (caller: datatable.js::initiateDatatables)
function exportAllData(dt, type, buttonContext, e, button, config) {
  const oldStart = dt.settings()[0]._iDisplayStart;
  const oldLength = dt.settings()[0]._iDisplayLength;

  // 1. Hook into the next AJAX request to ask for EVERYTHING
  dt.one("preXhr", function (e, s, data) {
    data.start = 0;
    data.length = -1;  // Controller logic MUST handle this
  });

  // 2. Once the data arrives, trigger the built-in export and revert the UI
  dt.one("draw", function () {
    if (type === "excel") {
      $.fn.dataTable.ext.buttons.excelHtml5.action.call(buttonContext, e, dt, button, config);
    } else {
      $.fn.dataTable.ext.buttons.csvHtml5.action.call(buttonContext, e, dt, button, config);
    }

    // 3. Revert table to original pagination so the user doesn't see 10,000 rows
    setTimeout(() => {
      dt.page.len(oldLength).page(Math.floor(oldStart / oldLength)).draw(false);
    }, 500);
  });

  dt.ajax.reload();
}

document.addEventListener("turbo:load", () => {
  if (
    document.querySelector("#passengers-table") ||
    document.querySelector("#rides-table") ||
    document.querySelector("#shift-rides-table")
  ) {
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
document.addEventListener("turbo:before-cache", () => {
  // Destroy all datatables before caching
  ["#passengers-table", "#rides-table", "#shift-rides-table"].forEach(
    (selector) => {
      const tableElement = document.querySelector(selector);
      if (tableElement && $.fn.DataTable.isDataTable(tableElement)) {
        $(tableElement).DataTable().destroy();
      }
    },
  );
});
