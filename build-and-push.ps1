# PowerShell Script לבנייה והעלאת Images ל-Docker Hub
# Usage: .\build-and-push.ps1 YOUR_DOCKER_USERNAME

param(
    [Parameter(Mandatory=$true)]
    [string]$DockerUsername
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "בנייה והעלאת Images ל-Docker Hub" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# בדיקה שהמשתמש התחבר
Write-Host "[1/5] בודק התחברות ל-Docker Hub..." -ForegroundColor Yellow
$loginCheck = docker info 2>&1 | Select-String "Username"
if (-not $loginCheck) {
    Write-Host "⚠️  לא נראה שהתחברת ל-Docker Hub" -ForegroundColor Yellow
    Write-Host "הרצי: docker login" -ForegroundColor Yellow
    $continue = Read-Host "להמשיך בכל זאת? (y/n)"
    if ($continue -ne "y") {
        exit 1
    }
}

# בניית CartService
Write-Host "[2/5] בונה CartService image..." -ForegroundColor Yellow
$cartServiceTag = "$DockerUsername/cartservice:latest"
docker build -t $cartServiceTag ./CartService
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ שגיאה בבניית CartService" -ForegroundColor Red
    exit 1
}
Write-Host "✅ CartService נבנה בהצלחה" -ForegroundColor Green
Write-Host ""

# בניית OrderService
Write-Host "[3/5] בונה OrderService image..." -ForegroundColor Yellow
$orderServiceTag = "$DockerUsername/orderservice:latest"
docker build -t $orderServiceTag ./OrderService
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ שגיאה בבניית OrderService" -ForegroundColor Red
    exit 1
}
Write-Host "✅ OrderService נבנה בהצלחה" -ForegroundColor Green
Write-Host ""

# העלאת CartService
Write-Host "[4/5] מעלה CartService ל-Docker Hub..." -ForegroundColor Yellow
docker push $cartServiceTag
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ שגיאה בהעלאת CartService" -ForegroundColor Red
    exit 1
}
Write-Host "✅ CartService הועלה בהצלחה" -ForegroundColor Green
Write-Host ""

# העלאת OrderService
Write-Host "[5/5] מעלה OrderService ל-Docker Hub..." -ForegroundColor Yellow
docker push $orderServiceTag
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ שגיאה בהעלאת OrderService" -ForegroundColor Red
    exit 1
}
Write-Host "✅ OrderService הועלה בהצלחה" -ForegroundColor Green
Write-Host ""

# עדכון docker-compose files
Write-Host "עדכון docker-compose files..." -ForegroundColor Yellow

# עדכון producer
$producerContent = Get-Content docker-compose.producer.yml -Raw
$producerContent = $producerContent -replace "YOUR_USERNAME", $DockerUsername
Set-Content docker-compose.producer.yml $producerContent

# עדכון consumer
$consumerContent = Get-Content docker-compose.consumer.yml -Raw
$consumerContent = $consumerContent -replace "YOUR_USERNAME", $DockerUsername
Set-Content docker-compose.consumer.yml $consumerContent

Write-Host "✅ docker-compose files עודכנו" -ForegroundColor Green
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ הכל הושלם בהצלחה!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Images שנוצרו:" -ForegroundColor Gray
Write-Host "  - $cartServiceTag" -ForegroundColor Gray
Write-Host "  - $orderServiceTag" -ForegroundColor Gray
Write-Host ""
Write-Host "כעת תוכלי להגיש:" -ForegroundColor Gray
Write-Host "  - docker-compose.producer.yml" -ForegroundColor Gray
Write-Host "  - docker-compose.consumer.yml" -ForegroundColor Gray
Write-Host "  - README.md" -ForegroundColor Gray
Write-Host ""
Write-Host "המרצה יוכל להריץ:" -ForegroundColor Gray
Write-Host "  docker-compose -f docker-compose.producer.yml up" -ForegroundColor Gray
Write-Host "  docker-compose -f docker-compose.consumer.yml up" -ForegroundColor Gray

