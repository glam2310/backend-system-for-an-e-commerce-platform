# PowerShell Script לבדיקת המערכת
# Usage: .\test-system.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "בדיקת CartService ו-OrderService" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# בדיקה 1: יצירת הזמנה
Write-Host "[1/5] בודק יצירת הזמנה..." -ForegroundColor Yellow
$orderId = "TEST-ORD-$(Get-Date -Format 'yyyyMMddHHmmss')"
$createOrderBody = @{
    orderId = $orderId
    numberOfItems = 3
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/Orders/create-order" `
        -Method POST `
        -ContentType "application/json" `
        -Body $createOrderBody
    
    Write-Host "✅ הזמנה נוצרה בהצלחה!" -ForegroundColor Green
    Write-Host "   Order ID: $($response.orderId)" -ForegroundColor Gray
    Write-Host "   Total Amount: $($response.totalAmount)" -ForegroundColor Gray
    Write-Host "   Number of Items: $($response.items.Count)" -ForegroundColor Gray
    Write-Host ""
    
    # שמירת totalAmount לחישוב shipping
    $totalAmount = $response.totalAmount
    $expectedShipping = [math]::Round($totalAmount * 0.02m, 2)
    
} catch {
    Write-Host "❌ שגיאה ביצירת הזמנה: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# המתנה ל-Consumer לעבד
Write-Host "[2/5] ממתין ל-Consumer לעבד את ההזמנה (5 שניות)..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# בדיקה 2: קבלת פרטי הזמנה
Write-Host "[3/5] בודק קבלת פרטי הזמנה..." -ForegroundColor Yellow
try {
    $orderDetails = Invoke-RestMethod -Uri "http://localhost:8081/api/Orders/order-details?orderId=$orderId" `
        -Method GET
    
    Write-Host "✅ פרטי הזמנה התקבלו בהצלחה!" -ForegroundColor Green
    Write-Host "   Order ID: $($orderDetails.order.orderId)" -ForegroundColor Gray
    Write-Host "   Total Amount: $($orderDetails.order.totalAmount)" -ForegroundColor Gray
    Write-Host "   Shipping Cost: $($orderDetails.shippingCost)" -ForegroundColor Gray
    Write-Host ""
    
    # בדיקת shipping cost
    $actualShipping = [math]::Round($orderDetails.shippingCost, 2)
    if ([math]::Abs($actualShipping - $expectedShipping) -lt 0.01) {
        Write-Host "✅ Shipping Cost נכון! ($actualShipping = 2% של $totalAmount)" -ForegroundColor Green
    } else {
        Write-Host "❌ Shipping Cost שגוי! צפוי: $expectedShipping, התקבל: $actualShipping" -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ שגיאה בקבלת פרטי הזמנה: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   וודאי שה-Consumer רץ וטיפל בהזמנה" -ForegroundColor Yellow
    exit 1
}

# בדיקה 3: Validation - OrderId ריק
Write-Host "[4/5] בודק Validation (OrderId ריק)..." -ForegroundColor Yellow
try {
    $invalidBody = @{
        orderId = ""
        numberOfItems = 3
    } | ConvertTo-Json
    
    Invoke-RestMethod -Uri "http://localhost:8080/api/Orders/create-order" `
        -Method POST `
        -ContentType "application/json" `
        -Body $invalidBody `
        -ErrorAction Stop
    
    Write-Host "❌ Validation נכשל - היה צריך להחזיר שגיאה!" -ForegroundColor Red
    
} catch {
    if ($_.Exception.Response.StatusCode -eq 400) {
        Write-Host "✅ Validation עובד כראוי - OrderId ריק נדחה" -ForegroundColor Green
    } else {
        Write-Host "⚠️  שגיאה לא צפויה: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# בדיקה 4: Order לא קיים
Write-Host "[5/5] בודק Order לא קיים..." -ForegroundColor Yellow
try {
    Invoke-RestMethod -Uri "http://localhost:8081/api/Orders/order-details?orderId=NON-EXISTENT-123" `
        -Method GET `
        -ErrorAction Stop
    
    Write-Host "❌ היה צריך להחזיר 404!" -ForegroundColor Red
    
} catch {
    if ($_.Exception.Response.StatusCode -eq 404) {
        Write-Host "✅ Order לא קיים מחזיר 404 כראוי" -ForegroundColor Green
    } else {
        Write-Host "⚠️  שגיאה לא צפויה: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ כל הבדיקות הושלמו!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "לבדיקות נוספות, ראי את TESTING_GUIDE.md" -ForegroundColor Gray

