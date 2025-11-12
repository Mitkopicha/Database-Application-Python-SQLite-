Database Application (Python + SQLite)

This is a **Python command-line application** that manages customers, baskets, and orders using an **SQLite database**.  
It was created as a university project focused on learning how to combine **Python programming** with **SQL-based data handling**.  
The system simulates a small online store where users can browse items, add them to a basket, and place orders — all stored locally in an SQLite database.

---
Features

- Store and manage data using **SQLite**
- Simple **command-line interface (CLI)** for interaction
- Shopper login using an existing ID
- View, add, update, or remove basket items
- Checkout to create and store customer orders
- Persistent data across sessions
- Structured error handling and clean database logic

---

## 📁 Project Structure
Database-Application-Python-SQLite-/
│
├── Assessment_Python&SQL.py # Main Python program
├── create_orinoco_db.sql # SQL script for database schema and seed data
├── AssessmentDB # SQLite database file (auto-generated after setup)
├── Python_code.txt # Backup copy of the main Python code
└── README.md # Project documentation

---

## ▶️ How to Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Mitkopicha/Database-Application-Python-SQLite-.git
   cd Database-Application-Python-SQLite-

2. Run the main script:
python Assessment_Python&SQL.py


3. Enter a shopper ID when prompted:
Enter your shopper id: 1
(You can use shopper ID 1 or 2, as defined in the SQL seed data.)

