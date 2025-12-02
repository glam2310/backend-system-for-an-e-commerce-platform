using OrderService.Models;

namespace OrderService.Services
{
    public class OrderDB
    {
        private readonly Dictionary<string, StoredOrder> _orders = new();

        public void Save(StoredOrder storedOrder)
        {
            _orders[storedOrder.Order.OrderId] = storedOrder;
        }

        public StoredOrder? Get(string orderId)
        {
            _orders.TryGetValue(orderId, out var value);
            return value;
        }
    }
}
