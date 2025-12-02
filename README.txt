# CartService & OrderService - E-commerce Backend System

## 1.full name and ID number

**Full Name:** Stav Glam  
**ID Number:** 322331984

---

## 2. The full URLs and type of API request to generate the producer and the consumer applications

### Producer Application (CartService)

**URL:** `http://localhost:8080/api/Orders/create-order`

**Request Type:** `POST`

**Content-Type:** `application/json`

### Consumer Application (OrderService)

**URL:** `http://localhost:8081/api/Orders/order-details?orderId={orderId}`

**סוג Request:** `GET`


## 3. What type of exchange you chose and why?

**Exchange Type:** `Fanout`

**Reason:**

1. **Broadcast Pattern**: According to the requirements, when a new order is created, it must be broadcast to multiple downstream services (inventory management, billing, shipping).
A Fanout exchange sends all messages to all queues bound to it.

2. **Simplicity**: In a Fanout exchange, all consumers receive a copy of every message. This fits our use case where all services need to receive all orders.

3. **Decoupling**: The Producer doesn't need to know how many consumers exist or who they are. It simply publishes to the exchange, and the exchange distributes to all bound queues.

4. **Scalability**: Easy to add more consumers in the future - simply bind a new queue to the exchange, and it will automatically start receiving messages.


## 4. Is there a binding key on the consumer? If so, what is it and why?

**NO, there isn't a binding key.**

**Value:** `""` (empty string)

**Reason:**

1. **Fanout Exchange Behavior**: In a Fanout exchange, the routing key is not used for routing. All messages are sent to all bound queues, regardless of the routing key.

2. **Standard Practice**: When using a Fanout exchange, it's standard practice to use an empty binding key, as it doesn't affect the behavior.

3. **Idempotent Binding**: Even if we use a different binding key, the result would be the same - all messages would still reach the queue.


## 5. Which service declared the exchange and queue and why?

### Exchange Declaration:

**Both services declare the Exchange:**
- **Producer (CartService)**: Declares the exchange before publishing messages
- **Consumer (OrderService)**: Declares the exchange before creating the queue binding

**Reason:**

1. **Idempotent Operation**: `ExchangeDeclare` is an idempotent operation - if the exchange already exists with the same parameters, the operation won't fail. This allows each service to declare the exchange independently.

2. **Independence**: Each service can start independently without depending on the startup order of other services. If the Consumer starts before the Producer, it can still declare the exchange.

3. **Durability**: The exchange is defined as durable (`durable: true`), so it persists even after RabbitMQ restarts.



