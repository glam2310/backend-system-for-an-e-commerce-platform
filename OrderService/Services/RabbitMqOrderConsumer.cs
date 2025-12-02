using System.Text;
using System.Text.Json;
using System.Threading;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using OrderService.Models;

namespace OrderService.Services
{
    public class RabbitMqOrderConsumer : BackgroundService
    {
        private readonly ILogger<RabbitMqOrderConsumer> _logger;
        private readonly OrderDB _db;  
        private readonly IConfiguration _configuration;

        public RabbitMqOrderConsumer(
            ILogger<RabbitMqOrderConsumer> logger,
            OrderDB db,
            IConfiguration configuration)  
        {
            _logger = logger;
            _db = db;
            _configuration = configuration;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            var hostName = _configuration["RabbitMq:Host"] ?? "rabbitmq";
            var factory = new ConnectionFactory { HostName = hostName };
            
            IConnection? connection = null;
            IModel? channel = null;

            // Retry connection logic
            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    if (connection == null || !connection.IsOpen)
                    {
                        connection = factory.CreateConnection();
                        _logger.LogInformation("Connected to RabbitMQ at {HostName}", hostName);
                    }

                    if (channel == null || channel.IsClosed)
                    {
                        channel = connection.CreateModel();
                    }

                    var exchangeName = _configuration["RabbitMq:ExchangeName"] ?? "orders-exchange";
                    channel.ExchangeDeclare(exchangeName, ExchangeType.Fanout, durable: true);

                    var queueName = "order-service-queue";
                    channel.QueueDeclare(queueName, durable: true, exclusive: false, autoDelete: false);

                    channel.QueueBind(queueName, exchangeName, "");

                    var consumer = new EventingBasicConsumer(channel);

                    consumer.Received += (model, ea) =>
                    {
                        try
                        {
                            var json = Encoding.UTF8.GetString(ea.Body.ToArray());
                            var order = JsonSerializer.Deserialize<Order>(json);

                            if (order == null)
                            {
                                _logger.LogWarning("Received null order");
                                return;
                            }

                            if (order.Status != "new")
                            {
                                _logger.LogInformation("Skipping order {OrderId} with status {Status}", order.OrderId, order.Status);
                                return;
                            }

                            var shipping = order.TotalAmount * 0.02m;

                            var stored = new StoredOrder
                            {
                                Order = order,
                                ShippingCost = shipping
                            };

                            _db.Save(stored);

                            _logger.LogInformation("Saved order {OrderId} with shipping {ShippingCost}",
                                order.OrderId, shipping);
                        }
                        catch (Exception ex)
                        {
                            _logger.LogError(ex, "Error processing order message");
                        }
                    };

                    channel.BasicConsume(queue: queueName, autoAck: true, consumer: consumer);
                    _logger.LogInformation("Started consuming messages from queue {QueueName}", queueName);

                    // Keep the task running
                    await Task.Delay(Timeout.Infinite, stoppingToken);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error connecting to RabbitMQ. Retrying in 5 seconds...");
                    await Task.Delay(5000, stoppingToken);
                }
            }
        }
    }
}
