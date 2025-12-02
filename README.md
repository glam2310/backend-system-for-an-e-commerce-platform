# **Project Summary**

This project implements a simplified **backend system** for an e-commerce platform using **RabbitMQ** in an **event-driven architecture**.

It contains two separate applications:
- **CartService (Producer)**
- **OrderService (Consumer)**

The system simulates how an e-commerce platform **broadcasts new orders** to multiple services such as **inventory**, **billing**, and **shipping**.

---

# **What the Project Does**

## **1. CartService – Producer Application**

### **API Endpoint**


### **Input**
The client provides only:
- **`orderId`**
- **`numberOfItems`**

### **Internal Auto-Generation**
The service automatically generates:
- **product list**
- **total amount**
- **random customer details**
- **timestamps**
- **order status: `"new"`**

### **Behavior**
- Publishes the generated order as a **JSON event** to RabbitMQ  
- Uses a **Fanout Exchange** to broadcast the event to all consumers  
- Performs strict **input validation**, returning meaningful error responses when necessary

---

## **2. OrderService – Consumer Application**

The service listens for **new order events** where:


### **When an event is received**
- Calculates shipping cost:

- Logs the order
- Stores it in an **in-memory data store** including the shipping cost

### **API Endpoint**


The endpoint:
- Receives an **orderId**
- Retrieves the stored order
- Returns **order details + shipping cost**

---

# ** Final Deliverables**

You must submit:

### **Two `docker-compose.yml` files**
- One for the **Producer**
- One for the **Consumer**

### **One README file containing**
- Full name & ID  
- Full API URLs and request types  
- Chosen exchange type + explanation  
- Binding key usage (or no binding key) + explanation  
- Which service declares the exchange & queue + why  

---



