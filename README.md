## 🧠 Developer Reflection
### 🔧 What was the hardest part?

**The hardest part was understanding the difference between:**

🧱 ***Clustered Index*** – only one allowed per table

🧩 ***Non-Clustered Index*** – can have many, used for faster searches

- I got an error trying to add a second clustered index, and fixing it helped me understand how indexing works. Another challenge was making sure BookID, MemberID, and LoanDate matched exactly when inserting payments — otherwise, the foreign key constraint would block the insert.

### 💡 What helped me think like a backend developer?

**Working with these SQL features made me feel like a real backend developer:**

🔄 ***Transactions*** – to safely roll back if something goes wrong

⚙️ ***Triggers*** – to automatically update book availability

📊 ***Functions*** – to calculate things like average ratings

🧰 ***Stored Procedures*** – to organize and reuse backend logic

- They helped me manage logic, performance, and consistency in the database.

### 🧪 How would I test this if it were a real app?

- 📚 Borrow or return a book → check that the book’s status updates

- 🚫 Try wrong input (like missing loan date) → make sure it’s rejected

- 🔍 Use SQL queries to test views, functions, and triggers

- 🧪 Use Postman or a basic UI to simulate real actions from users
