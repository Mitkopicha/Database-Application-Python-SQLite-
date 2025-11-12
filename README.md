Database Application (Python + SQLite)

This project is a command-line application built in Python that manages customer orders and shopping baskets using an SQLite database. It was developed as part of a university module focused on problem-solving through programming and database interaction.
The goal was to build a small but realistic store management system that lets users browse products, manage their basket, and place orders — all handled through SQL queries and Python logic.


Features:

SQLite database integration for data storage

Command-line interface (CLI) for an interactive user experience

Shopper login simulation using shopper IDs

View and manage baskets (add, remove, or update items)

Place and view orders with linked products and sellers

Data persistence between sessions

Error handling and clean database operations

🗂️ Project Structure

Database-Application-Python-SQLite-/
│
├── Assessment_Python&SQL.py      # Main Python program
├── create_orinoco_db.sql         # SQL script for creating tables and sample data
├── AssessmentDB                  # SQLite database file
├── Python_code.txt               # Text copy of the main code
└── README.md                     # Project documentation

⚙️ How to Run

Clone this repository:

git clone https://github.com/Mitkopicha/Database-Application-Python-SQLite-.git
cd Database-Application-Python-SQLite-


Run the program in Python:

python Assessment_Python&SQL.py


When prompted:

Enter your shopper id: 1


You can use shopper ID 1 or 2 (as defined in the SQL seed data).
