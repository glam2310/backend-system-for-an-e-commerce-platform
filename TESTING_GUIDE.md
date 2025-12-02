# מדריך בדיקה למערכת CartService ו-OrderService

## שלב 1: הפעלת השירותים

### הפעלת Producer (CartService):
```bash
docker-compose -f docker-compose.producer.yml up --build
```

### הפעלת Consumer (OrderService) - בטרמינל נפרד:
```bash
docker-compose -f docker-compose.consumer.yml up --build
```

**וודאי שהשירותים רצים:**
- CartService: http://localhost:8080/swagger
- OrderService: http://localhost:8081/swagger
- RabbitMQ Management: http://localhost:15672 (guest/guest)

---

## שלב 2: בדיקת יצירת הזמנה (Producer)

### בדיקה דרך Swagger:
1. פתחי http://localhost:8080/swagger
2. מצאי את ה-endpoint: `POST /api/Orders/create-order`
3. לחצי על "Try it out"
4. הכניסי JSON לדוגמה:
```json
{
  "orderId": "ORD-001",
  "numberOfItems": 3
}
```
5. לחצי "Execute"
6. **תוצאה צפויה**: Status 200 OK עם פרטי ההזמנה

### בדיקות Validation:
**בדיקה 1 - OrderId ריק:**
```json
{
  "orderId": "",
  "numberOfItems": 3
}
```
**תוצאה צפויה**: Status 400 Bad Request - "OrderId is required"

**בדיקה 2 - NumberOfItems שלילי:**
```json
{
  "orderId": "ORD-002",
  "numberOfItems": -1
}
```
**תוצאה צפויה**: Status 400 Bad Request - "NumberOfItems must be greater than 0"

**בדיקה 3 - Request body ריק:**
```json
null
```
**תוצאה צפויה**: Status 400 Bad Request - "Request body is required"

---

## שלב 3: בדיקת Consumer - קבלת הזמנות

### בדיקה אוטומטית:
לאחר יצירת הזמנה ב-CartService, ה-Consumer אמור:
1. לקבל את ההודעה מ-RabbitMQ
2. לבדוק שהסטטוס הוא "new"
3. לחשב shipping cost (2% מה-TotalAmount)
4. לשמור את ההזמנה ב-memory

**איך לבדוק:**
- בדקי את הלוגים של OrderService בטרמינל
- אמורה להופיע הודעה: "Saved order ORD-001 with shipping X.XX"

---

## שלב 4: בדיקת קבלת פרטי הזמנה (Consumer API)

### בדיקה דרך Swagger:
1. פתחי http://localhost:8081/swagger
2. מצאי את ה-endpoint: `GET /api/Orders/order-details`
3. לחצי על "Try it out"
4. הכניסי `orderId`: `ORD-001`
5. לחצי "Execute"
6. **תוצאה צפויה**: Status 200 OK עם:
```json
{
  "order": {
    "orderId": "ORD-001",
    "status": "new",
    "items": [...],
    "totalAmount": XXX.XX,
    "createdAt": "2024-..."
  },
  "shippingCost": XX.XX
}
```

### בדיקות Validation:
**בדיקה 1 - OrderId ריק:**
- השאירי את `orderId` ריק
- **תוצאה צפויה**: Status 400 Bad Request - "orderId is required"

**בדיקה 2 - OrderId שלא קיים:**
- הכניסי `orderId`: `ORD-999`
- **תוצאה צפויה**: Status 404 Not Found - "Order not found"

---

## שלב 5: בדיקת זרימה מלאה (End-to-End)

### תרחיש בדיקה מלא:
1. **יצירת הזמנה:**
   ```bash
   curl -X POST "http://localhost:8080/api/Orders/create-order" \
     -H "Content-Type: application/json" \
     -d '{"orderId": "ORD-TEST-001", "numberOfItems": 5}'
   ```

2. **המתנה 2-3 שניות** (לתת ל-Consumer לעבד)

3. **קבלת פרטי הזמנה:**
   ```bash
   curl "http://localhost:8081/api/Orders/order-details?orderId=ORD-TEST-001"
   ```

4. **וודאי שהתוצאה כוללת:**
   - פרטי ההזמנה המלאים
   - shippingCost = totalAmount * 0.02

---

## שלב 6: בדיקת RabbitMQ

### בדיקה דרך RabbitMQ Management UI:
1. פתחי http://localhost:15672
2. התחברי עם: `guest` / `guest`
3. לך ל-"Exchanges"
4. חפשי את `orders-exchange`
5. **וודאי שיש:**
   - Type: `fanout`
   - Durable: `true`
6. לך ל-"Queues"
7. חפשי את `order-service-queue`
8. **וודאי שיש:**
   - Binding ל-`orders-exchange`
   - Routing key: (ריק)

---

## שלב 7: בדיקת שגיאות

### בדיקת Producer ללא RabbitMQ:
1. עצרי את RabbitMQ: `docker stop <rabbitmq-container-id>`
2. נסי ליצור הזמנה
3. **תוצאה צפויה**: Status 500 Internal Server Error עם הודעת שגיאה

### בדיקת Consumer ללא RabbitMQ:
1. עצרי את RabbitMQ
2. הפעלי מחדש את OrderService
3. **תוצאה צפויה**: Consumer מנסה להתחבר מחדש כל 5 שניות (retry logic)

---

## בדיקות נוספות מומלצות:

### 1. בדיקת הזמנות מרובות:
```bash
# יצירת 3 הזמנות
curl -X POST "http://localhost:8080/api/Orders/create-order" -H "Content-Type: application/json" -d '{"orderId": "ORD-001", "numberOfItems": 2}'
curl -X POST "http://localhost:8080/api/Orders/create-order" -H "Content-Type: application/json" -d '{"orderId": "ORD-002", "numberOfItems": 4}'
curl -X POST "http://localhost:8080/api/Orders/create-order" -H "Content-Type: application/json" -d '{"orderId": "ORD-003", "numberOfItems": 1}'

# בדיקת כל אחת
curl "http://localhost:8081/api/Orders/order-details?orderId=ORD-001"
curl "http://localhost:8081/api/Orders/order-details?orderId=ORD-002"
curl "http://localhost:8081/api/Orders/order-details?orderId=ORD-003"
```

### 2. בדיקת חישוב Shipping Cost:
- צרי הזמנה עם `numberOfItems: 1`
- בדקי שה-shippingCost = totalAmount * 0.02
- לדוגמה: אם totalAmount = 100, אז shippingCost = 2.00

### 3. בדיקת Status Filtering:
- אם יש הזמנה עם status != "new", היא לא אמורה להישמר ב-Consumer
- (כרגע כל ההזמנות נוצרות עם status="new", אז זה לא רלוונטי כרגע)

---

## סיכום בדיקות מוצלחות:

✅ Producer יוצר הזמנות בהצלחה  
✅ Validation עובד כראוי  
✅ Consumer מקבל ומעבד הזמנות  
✅ Shipping cost מחושב נכון (2% מה-totalAmount)  
✅ API של Consumer מחזיר פרטי הזמנות  
✅ שגיאות מטופלות כראוי  
✅ RabbitMQ Exchange ו-Queue מוגדרים נכון  

---

## בעיות נפוצות ופתרונות:

**בעיה**: Consumer לא מקבל הזמנות
- **פתרון**: וודאי ש-RabbitMQ רץ ושם ה-exchange תואם

**בעיה**: Port already in use
- **פתרון**: עצרי containers קיימים: `docker-compose down`

**בעיה**: Cannot connect to RabbitMQ
- **פתרון**: המתן 10-15 שניות לאחר הפעלת RabbitMQ (זמן אתחול)

**בעיה**: Order not found
- **פתרון**: וודאי שהזמנה נוצרה ו-Consumer עיבד אותה (בדקי לוגים)

