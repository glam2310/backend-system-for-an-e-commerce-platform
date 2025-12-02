Project Summary

This project implements a simplified backend system for an e-commerce platform using RabbitMQ event-driven communication. It consists of two applications: CartService (Producer) and OrderService (Consumer). The goal is to simulate how a real e-commerce system broadcasts new orders to multiple downstream services such as inventory, billing, and shipping.

What the Project Does
1. CartService – Producer Application

The CartService exposes an API endpoint (/create-order) that allows a customer to create a new order.
The client sends only two fields:

orderId

numberOfItems

The service then automatically generates the full order object internally, including fields such as:

product list

total amount

random customer details

timestamps

order status (“new”)

After the order is generated and validated:

The CartService publishes the order as a JSON event to RabbitMQ.

The event is broadcast to all consumers using a Fanout exchange.

Input validation is enforced, and invalid requests return appropriate error responses.

2. OrderService – Consumer Application

The OrderService connects to RabbitMQ and listens for new order events (orders where status = "new").

When a new order message arrives:

It calculates the shipping cost, defined as:
shippingCost = 2% of totalAmount

It logs the order and stores it in an in-memory data store (for example, a simple dictionary or in-memory DB).

It exposes its own API endpoint (/order-details) that:

receives an orderId

retrieves the stored order

returns the order details including the calculated shipping cost

Final Deliverables

You must submit:

Two docker-compose.yml files (one for producer, one for consumer)

One README file answering:

your full name & ID

API URLs and request types

chosen exchange type and reasoning

binding key explanation

which service declares the exchange/queue and why

The system must run correctly via Docker Compose, and all API endpoints must be reachable—otherwise the project receives 0.
