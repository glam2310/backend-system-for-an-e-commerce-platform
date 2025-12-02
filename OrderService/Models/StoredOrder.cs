namespace OrderService.Models
{
    public class StoredOrder
    {
        public Order Order { get; set; } = default!;
        public decimal ShippingCost { get; set; }
    }
}
