namespace CartService.Models
{
    public class Order
    {
        public string OrderId { get; set; } = null!;
        public string Status { get; set; } = "new";
        public List<OrderItem> Items { get; set; } = new List<OrderItem>();
        public decimal TotalAmount { get; set; } = 0;
        public DateTime CreatedAt { get; set; }





    }
}
