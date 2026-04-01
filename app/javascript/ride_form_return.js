document.addEventListener("turbo:load", function () {
    const rideForm = document.querySelector('form[action="/rides"]');
    if (!rideForm) {
        return;
    }

    const createPassengerLink = document.querySelector("[data-save-ride-draft='true']");
    if (createPassengerLink) {
        createPassengerLink.addEventListener("click", function () {
            saveRideFormDraft(rideForm);
        });
    }

    const draft = loadRideFormDraft();
    if (draft && draft.path === window.location.pathname) {
        restoreRideFormDraft(rideForm, draft);
    }

    const url = new URL(window.location.href);
    const selectedPassengerId = url.searchParams.get("selected_passenger_id");

    if (selectedPassengerId) {
        selectPassengerById(selectedPassengerId);
        url.searchParams.delete("selected_passenger_id");
        window.history.replaceState({}, "", url.toString());
    }

    if (draft && draft.path === window.location.pathname) {
        clearRideFormDraft();
    }
});

function saveRideFormDraft(form) {
    const formState = Array.from(form.elements)
        .filter((element) => shouldPersistElement(element))
        .map((element) => ({
            name: element.name,
            type: element.type,
            value: element.value,
            checked: element.checked,   
        }));

    const draft = {
        path: window.location.pathname,
        stopCount: document.querySelectorAll("#stops-container .col-md-12.mb-4").length,
        formState: formState,
    };

    sessionStorage.setItem("rideFormDraft", JSON.stringify(draft));
}

function loadRideFormDraft() {
    const savedDraft = sessionStorage.getItem("rideFormDraft");
    if (!savedDraft) {
        return null;
    }

    try {
        return JSON.parse(savedDraft);
    } catch (error) {
        clearRideFormDraft();
        return null; 
    }
}

function clearRideFormDraft() {
    sessionStorage.removeItem("rideFormDraft");
}

function restoreRideFormDraft(form, draft) {
    ensureStopCount(draft.stopCount || 1); 

    const fieldOccurences = {};

    draft.formState.forEach((savedField) => {
        const occurenceIndex = fieldOccurences[savedField.name] || 0;
        fieldOccurences[savedField.name] = occurenceIndex + 1;

        const matchingElements = Array.from(form.elements).filter(
            (element) => element.name === savedField.name,
        );
        const targetElement = matchingElements[occurenceIndex];

        if (!targetElement) {
            return;
        }

        if (targetElement.type === "checkbox" || targetElement.type === "radio") {
            targetElement.checked = savedField.checked;
        } else {
            targetElement.value = savedField.value;
        }

        targetElement.dispatchEvent(new Event("input", { bubbles: true }));
        targetElement.dispatchEvent(new Event("change", { bubbles: true }));
    });
}

function ensureStopCount(targetStopCount) {
    const stopsContainer = document.getElementById("stops-container");
    if (!stopsContainer) {
        return;
    }

    while (stopsContainer.querySelectorAll(".col-md-12.mb-4").length < targetStopCount) {
        const addButtons = stopsContainer.querySelectorAll(".add-stop-button");
        const lastAddButton = addButtons[addButtons.length - 1];

        if (!lastAddButton) {
            break;
        }

        lastAddButton.click(); 
    }
}

function shouldPersistElement(element) {
    if (!element.name || element.disabled) {
        return false;
    }

    return ![
        "button",
        "submit",
        "reset",
        "file",
    ].includes(element.type); 
}

function selectPassengerById(passengerId) {
    if (typeof gon === "undefined" || !gon.passengers) {
        return;
    }

    const passenger = gon.passengers.find(
        (candidate) => String(candidate.id) === String(passengerId),
    );

    if (!passenger) {
        return;
    }

    const passengerInput = $("#ride_passenger_name");
    if (!passengerInput.length) {
        return;
    }

    passengerInput.val(passenger.label); 
    passengerInput.trigger("autocompleteselect", { item: passenger });
}