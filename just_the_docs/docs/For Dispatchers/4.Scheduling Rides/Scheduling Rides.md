---
layout: default
title: Scheduling Rides
parent: Instruction for Dispatchers
permalink: /docs/For Dispatchers/Scheduling Rides.html
nav_order: 4
---

## Scheduling Rides

---

Adding a new ride to the database can be done either from the all rides table or from the shift you are scheduling a ride for. Both lead to the same ride creation page.

---

### Creating A New Ride from the Rides History Page

If you ever need to create a new ride without the specific shift yet, you can do so from the Rides History Page. We expect this use case will be rare.

Scroll to the bottom of the Rides History Page. Click the green “Add a Ride” button, which will take you to the Ride Creation Page.

<img src="4.Scheduling Rides/Scheduling Rides_1.png" alt="Scheduling Rides_1.png" width="60%" />

---

### Scheduling A New Ride from the Shift Page
This is where we expect most rides will be created from

1. Navigate to the shift you want to create a ride for. For example, here I am navigating to the am shift with John on June 2nd.

    <img src="4.Scheduling Rides/Scheduling Rides_2.png" alt="Scheduling Rides_2.png" width="100%" />

2. This will take you to the shift view page. Here, you can see the current rides for the shift, add new rides, and edit the text field with the timeline and notes that the driver will be able to see.

    <img src="4.Scheduling Rides/Scheduling Rides_3.png" alt="Scheduling Rides_3.png" width="100%" />

**Some things to note about this page**

- The estimated timeline is entered completely manually. There is no automated generation with it
- Remember to click “Save” before you leave the page
- Clicking “Edit this Shift” allows you to edit the shift date, type, and associated driver.
From this page, you can click “Add new ride”. This takes you to the ride creation page, with the driver prefilled from the shift information.

---

### Ride Creation Form

From the ride creation page, you can enter in the information about the ride.
There are some notable aspects to the page:

---

### Passenger Autocomplete

If you start typing in a passenger’s name, it will start prompting you with the names of passengers currently in the system

<img src="4.Scheduling Rides/Scheduling Rides_4.png" alt="Scheduling Rides_4.png" width="80%" />

If the passenger is new, you can select the “New Passenger” button to be taken to the passenger creation page. 
Upon selecting a passenger, the following boxes with the passenger information will automatically fill.

<img src="4.Scheduling Rides/Scheduling Rides_5.png" alt="Scheduling Rides_5.png" width="60%" />

If the passenger’s information needs to be updated, that cannot be done from this page. Instead, find the passenger in the master passenger list and update the information there.

---

### Selecting Stops

When you create a new ride, you can select an arbitrary number of stops. We expect this will primarily be used for round-trip rides, but it can also be used if a passenger has multiple destinations.

Initially, the destinations section will look like this. The origin address is automatically filled in with the home address of the passenger (this can be overwritten, however). 

<img src="4.Scheduling Rides/Scheduling Rides_6.png" alt="Scheduling Rides_6.png" width="50%" />

If there is more than one destination (including if the trip is round trip), simply click “Add Stop” to add an additional destination. You can add as many destinations as needed.

<img src="4.Scheduling Rides/Scheduling Rides_7.png" alt="Scheduling Rides_7.png" width="50%" />

There is no special indicator for round-trip rides. Just select the home address as the final stop.

