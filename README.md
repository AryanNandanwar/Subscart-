# Subscart Sprint - Rescheduling Delivery Slots

## 📌 Project Overview
This project implements the **Rescheduling Delivery Slots** feature for the Subscart Sprint evaluation.  
The main objective is to allow users to **reschedule meal delivery slots within the subscription validity period**, ensuring that:
- If the selected time slot has already passed, the **next available time slot** is auto-selected.
- Updated data is reflected in the **MongoDB database** after rescheduling.

The project is built with:
- **Backend:** Node.js + Express (API) with MongoDB (hardcoded data)
- **Frontend:** Flutter (for UI and interactions)

---

## ✅ Features Implemented
- Display of **subscription validity dates** and delivery slots for each day.
- Ability to:
  - Move a **delivery slot** to another day.
  - Auto-select the **next available time slot** if the chosen time has already passed.
- Updated schedule is stored in the **MongoDB database**.
- API integration between Flutter frontend and Node.js backend.

---


│ └── lib/ # Flutter application
└── README.md


---

