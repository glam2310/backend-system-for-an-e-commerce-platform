using CartService.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;
using CartService.Services;


namespace CartService.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class OrdersController : ControllerBase
    {
        private readonly RabbitMqPublisher _publisher;
        public OrdersController(RabbitMqPublisher publisher)
        {
            _publisher = publisher;
        }


        [HttpPost("create-order")]
        public IActionResult CreateOrder([FromBody] CreateOrderRequest request)
        {
            try
            {
                if (request == null)
                    return BadRequest("Request body is required");

                if (string.IsNullOrWhiteSpace(request.OrderId))
                    return BadRequest("OrderId is required");
                if (request.NumberOfItems <= 0)
                    return BadRequest("NumberOfItems must be greater than 0");

                Order newOrder = new Order();
                newOrder.CreatedAt = DateTime.UtcNow;
                newOrder.OrderId = request.OrderId;

                var random = new Random();
                for (int i = 0; i < request.NumberOfItems; i++)
                {
                    string productId = "P" + random.Next(1000, 9999);
                    int quantity = random.Next(1, 5);
                    decimal price = random.Next(10, 200);

                    OrderItem item = new OrderItem();
                    item.ProductId = productId;
                    item.Quantity = quantity;
                    item.Price = price;

                    newOrder.Items.Add(item);
                    newOrder.TotalAmount += price * quantity;

                }
                _publisher.PublishOrder(newOrder);
                return Ok(newOrder);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }

    }
}
