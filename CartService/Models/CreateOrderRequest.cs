namespace CartService.Models
{
    public class CreateOrderRequest
    {
        public string OrderId { get; set; } = null!;
        public int NumberOfItems { get; set; }

    }
}
