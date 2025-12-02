#!/bin/bash
# Bash Script לבדיקת המערכת
# Usage: ./test-system.sh

echo "========================================"
echo "בדיקת CartService ו-OrderService"
echo "========================================"
echo ""

# בדיקה 1: יצירת הזמנה
echo "[1/5] בודק יצירת הזמנה..."
ORDER_ID="TEST-ORD-$(date +%Y%m%d%H%M%S)"
CREATE_ORDER_BODY="{\"orderId\": \"$ORDER_ID\", \"numberOfItems\": 3}"

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "http://localhost:8080/api/Orders/create-order" \
  -H "Content-Type: application/json" \
  -d "$CREATE_ORDER_BODY")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" -eq 200 ]; then
  echo "✅ הזמנה נוצרה בהצלחה!"
  echo "   Order ID: $ORDER_ID"
  TOTAL_AMOUNT=$(echo "$BODY" | grep -o '"totalAmount":[0-9.]*' | cut -d':' -f2)
  echo "   Total Amount: $TOTAL_AMOUNT"
  
  # חישוב shipping צפוי
  EXPECTED_SHIPPING=$(echo "$TOTAL_AMOUNT * 0.02" | bc)
  echo ""
else
  echo "❌ שגיאה ביצירת הזמנה: HTTP $HTTP_CODE"
  echo "$BODY"
  exit 1
fi

# המתנה ל-Consumer לעבד
echo "[2/5] ממתין ל-Consumer לעבד את ההזמנה (5 שניות)..."
sleep 5

# בדיקה 2: קבלת פרטי הזמנה
echo "[3/5] בודק קבלת פרטי הזמנה..."
ORDER_DETAILS_RESPONSE=$(curl -s -w "\n%{http_code}" "http://localhost:8081/api/Orders/order-details?orderId=$ORDER_ID")
ORDER_DETAILS_HTTP_CODE=$(echo "$ORDER_DETAILS_RESPONSE" | tail -n1)
ORDER_DETAILS_BODY=$(echo "$ORDER_DETAILS_RESPONSE" | sed '$d')

if [ "$ORDER_DETAILS_HTTP_CODE" -eq 200 ]; then
  echo "✅ פרטי הזמנה התקבלו בהצלחה!"
  SHIPPING_COST=$(echo "$ORDER_DETAILS_BODY" | grep -o '"shippingCost":[0-9.]*' | cut -d':' -f2)
  echo "   Shipping Cost: $SHIPPING_COST"
  echo ""
  
  # בדיקת shipping cost (עם tolerance קטן)
  DIFF=$(echo "$SHIPPING_COST - $EXPECTED_SHIPPING" | bc | awk '{if ($1<0) print -$1; else print $1}')
  if (( $(echo "$DIFF < 0.01" | bc -l) )); then
    echo "✅ Shipping Cost נכון! ($SHIPPING_COST = 2% של $TOTAL_AMOUNT)"
  else
    echo "❌ Shipping Cost שגוי! צפוי: $EXPECTED_SHIPPING, התקבל: $SHIPPING_COST"
  fi
else
  echo "❌ שגיאה בקבלת פרטי הזמנה: HTTP $ORDER_DETAILS_HTTP_CODE"
  echo "$ORDER_DETAILS_BODY"
  echo "   וודאי שה-Consumer רץ וטיפל בהזמנה"
  exit 1
fi

# בדיקה 3: Validation - OrderId ריק
echo "[4/5] בודק Validation (OrderId ריק)..."
VALIDATION_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "http://localhost:8080/api/Orders/create-order" \
  -H "Content-Type: application/json" \
  -d '{"orderId": "", "numberOfItems": 3}')
VALIDATION_HTTP_CODE=$(echo "$VALIDATION_RESPONSE" | tail -n1)

if [ "$VALIDATION_HTTP_CODE" -eq 400 ]; then
  echo "✅ Validation עובד כראוי - OrderId ריק נדחה"
else
  echo "❌ Validation נכשל - היה צריך להחזיר 400!"
fi

# בדיקה 4: Order לא קיים
echo "[5/5] בודק Order לא קיים..."
NOT_FOUND_RESPONSE=$(curl -s -w "\n%{http_code}" "http://localhost:8081/api/Orders/order-details?orderId=NON-EXISTENT-123")
NOT_FOUND_HTTP_CODE=$(echo "$NOT_FOUND_RESPONSE" | tail -n1)

if [ "$NOT_FOUND_HTTP_CODE" -eq 404 ]; then
  echo "✅ Order לא קיים מחזיר 404 כראוי"
else
  echo "⚠️  צפוי 404, התקבל: $NOT_FOUND_HTTP_CODE"
fi

echo ""
echo "========================================"
echo "✅ כל הבדיקות הושלמו!"
echo "========================================"
echo ""
echo "לבדיקות נוספות, ראי את TESTING_GUIDE.md"

