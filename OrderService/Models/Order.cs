namespace OrderService.Models
{
    public class Order
    {
        public string OrderId { get; set; } = "";
        public DateTime CreatedAt { get; set; }
        public decimal TotalAmount { get; set; }
        public List<OrderItem> Items { get; set; } = new();
        public string Status { get; set; } = "";
    }
}
