using Microsoft.AspNetCore.Mvc;
using OrderService.Services;
using System;
using System.ComponentModel.DataAnnotations;

namespace OrderService.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class OrdersController : ControllerBase
    {
        private readonly OrderDB _db;

        public OrdersController(OrderDB db)
        {
            _db = db;
        }

        /// <summary>
        /// Gets order details by order ID
        /// </summary>
        /// <param name="orderId">The order ID to retrieve</param>
        /// <returns>Order details with shipping cost</returns>
        [HttpGet("order-details")]
        public IActionResult GetOrderDetails([FromQuery][Required] string orderId)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(orderId))
                    return BadRequest("orderId is required");

                var stored = _db.Get(orderId);
                if (stored == null)
                    return NotFound("Order not found");

                return Ok(new
                {
                    order = stored.Order,
                    shippingCost = stored.ShippingCost
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }
    }
}
