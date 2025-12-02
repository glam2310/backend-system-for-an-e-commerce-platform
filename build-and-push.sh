#!/bin/bash
# Bash Script לבנייה והעלאת Images ל-Docker Hub
# Usage: ./build-and-push.sh YOUR_DOCKER_USERNAME

if [ -z "$1" ]; then
    echo "❌ שגיאה: צריך לספק שם משתמש Docker Hub"
    echo "Usage: ./build-and-push.sh YOUR_DOCKER_USERNAME"
    exit 1
fi

DOCKER_USERNAME=$1

echo "========================================"
echo "בנייה והעלאת Images ל-Docker Hub"
echo "========================================"
echo ""

# בדיקה שהמשתמש התחבר
echo "[1/5] בודק התחברות ל-Docker Hub..."
if ! docker info | grep -q "Username"; then
    echo "⚠️  לא נראה שהתחברת ל-Docker Hub"
    echo "הרצי: docker login"
    read -p "להמשיך בכל זאת? (y/n) " continue
    if [ "$continue" != "y" ]; then
        exit 1
    fi
fi

# בניית CartService
echo "[2/5] בונה CartService image..."
CART_SERVICE_TAG="$DOCKER_USERNAME/cartservice:latest"
docker build -t "$CART_SERVICE_TAG" ./CartService
if [ $? -ne 0 ]; then
    echo "❌ שגיאה בבניית CartService"
    exit 1
fi
echo "✅ CartService נבנה בהצלחה"
echo ""

# בניית OrderService
echo "[3/5] בונה OrderService image..."
ORDER_SERVICE_TAG="$DOCKER_USERNAME/orderservice:latest"
docker build -t "$ORDER_SERVICE_TAG" ./OrderService
if [ $? -ne 0 ]; then
    echo "❌ שגיאה בבניית OrderService"
    exit 1
fi
echo "✅ OrderService נבנה בהצלחה"
echo ""

# העלאת CartService
echo "[4/5] מעלה CartService ל-Docker Hub..."
docker push "$CART_SERVICE_TAG"
if [ $? -ne 0 ]; then
    echo "❌ שגיאה בהעלאת CartService"
    exit 1
fi
echo "✅ CartService הועלה בהצלחה"
echo ""

# העלאת OrderService
echo "[5/5] מעלה OrderService ל-Docker Hub..."
docker push "$ORDER_SERVICE_TAG"
if [ $? -ne 0 ]; then
    echo "❌ שגיאה בהעלאת OrderService"
    exit 1
fi
echo "✅ OrderService הועלה בהצלחה"
echo ""

# עדכון docker-compose files
echo "עדכון docker-compose files..."

# עדכון producer
sed -i.bak "s/YOUR_USERNAME/$DOCKER_USERNAME/g" docker-compose.producer.yml
rm docker-compose.producer.yml.bak 2>/dev/null

# עדכון consumer
sed -i.bak "s/YOUR_USERNAME/$DOCKER_USERNAME/g" docker-compose.consumer.yml
rm docker-compose.consumer.yml.bak 2>/dev/null

echo "✅ docker-compose files עודכנו"
echo ""

echo "========================================"
echo "✅ הכל הושלם בהצלחה!"
echo "========================================"
echo ""
echo "Images שנוצרו:"
echo "  - $CART_SERVICE_TAG"
echo "  - $ORDER_SERVICE_TAG"
echo ""
echo "כעת תוכלי להגיש:"
echo "  - docker-compose.producer.yml"
echo "  - docker-compose.consumer.yml"
echo "  - README.md"
echo ""
echo "המרצה יוכל להריץ:"
echo "  docker-compose -f docker-compose.producer.yml up"
echo "  docker-compose -f docker-compose.consumer.yml up"

