# מדריך העלאת Images ל-Docker Hub

## שלב 1: יצירת חשבון Docker Hub

1. היכנסי ל-https://hub.docker.com
2. צרי חשבון (אם אין לך)
3. זכרי את שם המשתמש שלך (username)

---

## שלב 2: התחברות ל-Docker Hub מהטרמינל

```bash
docker login
```

הכנסי את שם המשתמש והסיסמה שלך.

---

## שלב 3: בניית Images

### בניית CartService Image:

```bash
docker build -t YOUR_USERNAME/cartservice:latest ./CartService
```

**החלפי `YOUR_USERNAME` בשם המשתמש שלך ב-Docker Hub!**

### בניית OrderService Image:

```bash
docker build -t YOUR_USERNAME/orderservice:latest ./OrderService
```

**דוגמה:**
אם שם המשתמש שלך הוא `stavglam`, אז:
```bash
docker build -t stavglam/cartservice:latest ./CartService
docker build -t stavglam/orderservice:latest ./OrderService
```

---

## שלב 4: העלאת Images ל-Docker Hub

```bash
docker push YOUR_USERNAME/cartservice:latest
docker push YOUR_USERNAME/orderservice:latest
```

**דוגמה:**
```bash
docker push stavglam/cartservice:latest
docker push stavglam/orderservice:latest
```

**הערה:** זה יכול לקחת כמה דקות, תלוי בגודל ה-images.

---

## שלב 5: עדכון docker-compose files

אחרי שהעלית את ה-images, צריך לעדכן את ה-docker-compose files להשתמש ב-images במקום build.

ראה את הקבצים:
- `docker-compose.producer.yml` (עודכן)
- `docker-compose.consumer.yml` (עודכן)

---

## בדיקה מקומית

לפני הגשה, בדקי שהכל עובד:

```bash
# Producer
docker-compose -f docker-compose.producer.yml up

# Consumer (בטרמינל אחר)
docker-compose -f docker-compose.consumer.yml up
```

---

## מה המרצה צריך לעשות

המרצה פשוט יריץ:

```bash
docker-compose -f docker-compose.producer.yml up
docker-compose -f docker-compose.consumer.yml up
```

Docker יוריד אוטומטית את ה-images מ-Docker Hub!

---

## טיפים:

1. **שם המשתמש:** ודאי שהשם ב-docker-compose תואם לשם ב-Docker Hub
2. **Public/Private:** Images צריכים להיות Public (או שהמרצה צריך גישה)
3. **Tags:** אפשר להשתמש ב-`latest` או ב-tag ספציפי כמו `v1.0`

---

## פתרון בעיות:

**אם push נכשל:**
- ודאי שהתחברת: `docker login`
- ודאי שהשם נכון: `YOUR_USERNAME/repository-name`
- ודאי שה-repository קיים ב-Docker Hub (נוצר אוטומטית ב-push הראשון)

**אם pull נכשל:**
- ודאי שה-image הוא Public
- ודאי שהשם ב-docker-compose תואם לשם ב-Docker Hub

