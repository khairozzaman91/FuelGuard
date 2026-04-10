# ⛽ FuelGuard – Intelligent Fuel Monitoring & Distribution System

**FuelGuard** is a robust full-stack solution designed to streamline and secure fuel distribution at stations. It leverages a high-performance **Go (Golang)** backend and a cross-platform **Flutter** frontend to ensure real-time monitoring, prevent fuel hoarding, and manage operator approvals.

### 🚀 Project Status
- **Frontend:** 🟢 90% Completed (Core UI & OCR Logic implemented).
- **Backend:** 🟡 In Progress (API development and Database integration are ongoing).

---

## 🛠️ Technical Architecture

### **Frontend (The User Interface)**
* **Framework:** **Flutter** (Dart) for a sleek, responsive mobile experience.
* **Key Features:**
  - Integrated **OCR (Optical Character Recognition)** for license plate scanning.
  - Role-based Dashboards (Admin & Operator).
  - Secure state management using **Provider/setState**.
* **Status:** Most of the UI and local logic are finalized.

### **Backend (The Core)**
* **Engine:** Go (Golang) using the **Gin Gonic** framework.
* **Database:** **PostgreSQL** (Supabase) with **GORM**.
* **Security:** Implementing **JWT** for authentication and **Bcrypt** for hashing.
* **Status:** Current focus is on finalizing UUID migration and securing Admin-only routes.

---

## 🌟 Key Functional Modules

### 1. Secure Authentication & Authorization
- **Registration:** Operators apply via the app.
- **Approval System:** Admin must approve accounts before they gain access.
- **JWT Protection:** Securing API endpoints to prevent unauthorized data leaks.

### 2. Intelligent Distribution Logic
- **Eligibility Check:** Automated backend logic to verify if a vehicle is allowed to receive fuel based on transaction history.
- **Live Monitoring:** Real-time sale tracking for Admins.

---

## 📂 Project Directory Overview

### **Frontend (`/lib`)**
- `services/api_service.dart`: The communication bridge (integration in progress).
- `features/auth/`: Login and Registration UI.
- `features/admin/`: Admin controls and approval screens.

### **Backend (`/server`)**
- `models/`: Database schema (transitioning to UUID).
- `handlers/`: Processing logic for fuel entry and user management.
- `middleware/`: Auth and Role validation.

---

## 📈 Future Roadmap
- [ ] Complete the remaining Backend API handlers.
- [ ] Fully integrate the Flutter frontend with the Go backend services.
- [ ] Implement data visualization (Charts/Graphs) in the Admin dashboard.
- [ ] Testing and Bug fixing.

---

**Developer:** Emon Rana (Prince)  
**Specialization:** Backend Development (Go) | Mobile App Development (Flutter)
