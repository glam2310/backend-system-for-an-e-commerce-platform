using Microsoft.Extensions.Configuration;
using RabbitMQ.Client;
using System.Text;
using System.Text.Json;
using CartService.Models;
using System;


namespace CartService.Services
{
    public class RabbitMqPublisher
    {
        private readonly string _host;
        public RabbitMqPublisher(IConfiguration configuration)
        {
            _host = configuration["RabbitMq:Host"]?? "localhost";
        }

        public void PublishOrder(Order order)
        {
            try
            {
                if (order == null)
                    throw new ArgumentNullException(nameof(order));

                var jsonString = JsonSerializer.Serialize(order);
                var body = Encoding.UTF8.GetBytes(jsonString);

                var factory = new ConnectionFactory() { HostName = _host };
                using var connection = factory.CreateConnection();
                using var channel = connection.CreateModel();

                channel.ExchangeDeclare(exchange: "orders-exchange", type: "fanout", durable: true, autoDelete: false);
                channel.BasicPublish(exchange: "orders-exchange", routingKey: string.Empty, basicProperties: null, body: body);
            }
            catch (Exception ex)
            {
                throw new Exception($"Failed to publish order to RabbitMQ: {ex.Message}", ex);
            }
        }




    }
}
