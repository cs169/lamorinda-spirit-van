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

// Creates the Datatables
const initiateDatatables = () => {
  const tables = [
    { selector: "#passengers-table", order: [[2, "asc"]] },
    { selector: "#rides-table", order: [[3, "desc"]] },
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

      // Hide (Street, City, Zip) cols after initialization for passenger table
      if (table.selector == "#passengers-table") {
        [5, 6, 7].forEach((idx) => newTable.column(idx).visible(false));
      }

      initiateCheckboxes(newTable);
      initiateSearchbars(newTable);
      updateFilterIndicator(newTable, table.selector);

      // Rebuild searchbars on column reorder
      newTable.on("column-reorder", function () {
        initiateSearchbars(newTable);
      });
    }
  });
};

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
