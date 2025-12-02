using CartService.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddSingleton<RabbitMqPublisher>();


builder.WebHost.UseUrls("http://0.0.0.0:8080");

var app = builder.Build();


app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "CartService API V1");
});


// app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
