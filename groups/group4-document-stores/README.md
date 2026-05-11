# Document Stores

## Group Members
- Luca Raichle  
- Lars Wieck  

---

## Overview

This project is part of the *Advanced Data Models* course and focuses on **Document Stores**, a category of NoSQL databases.

Document databases store data as **JSON-like documents** instead of rows and tables. This allows a **flexible schema**, where each document can have a different structure, making them especially suitable for **semi-structured or evolving data**.

In our presentation and demo, we:
- Explain the **document data model** and its key concepts  
- Compare document stores to relational databases  
- Demonstrate practical usage with **MongoDB**  
- Provide an interactive notebook for hands-on learning  

---

## Setup Instructions (Demo)

To run the demo, you need a free MongoDB cloud database.

### 1. Create a MongoDB Atlas Account
1. Go to: https://www.mongodb.com/products/platform/atlas-database  
2. Sign up and log in  
3. Create a **Free Tier Cluster (M0)**  
   - Cloud provider: any (e.g., AWS)  
   - Region: choose something close (e.g., Frankfurt)  

---

### 2. Create a Database User
1. Go to **Database Access**  
2. Click **Add New Database User**  
3. Choose:
   - Username: your choice  
   - Password: **save this!** (you’ll need it later)  
4. Give the user **Read and Write permissions**

---

### 3. Get Your Connection String
1. Go to your cluster → click **Connect**  
2. Choose **Connect your application**  
3. Select **Python**  
4. Copy the connection string, which looks like:
>mongodb+srv://<username>:<password>@cluster0.xxxxx.mongodb.net/

---

### 4. Configure the Notebook
1. Open the demo notebook (`demo/`)  
2. Replace:
- `<username>` with your database username  
- `<password>` with your password  

Now you’re ready to run the demo 🎉

---

## Directory Contents

- `slides/`  
Presentation slides used in the lecture  

- `demo/`  
products.json and Python notebook demonstrating:
  - inserting documents  
  - querying nested data  
  - working with flexible schemas  

- `notebooks/`  
Interactive exercises for students:
  - tasks (challenge notebook)  
  - solutions   

---

## Learning Goals

After working with this repository, you should understand:

- How document databases store data as self-contained documents
- Why flexible schemas are useful for modern applications  
- How queries differ from SQL (no joins)  
- When to use embedding vs. referencing in data modeling  

---

## Technologies Used

- MongoDB Atlas (cloud database)  
- Python (Jupyter Notebook)  
- JSON / BSON data model  