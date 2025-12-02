# מדריך הגשה - מה צריך להגיש?

## שאלה: מה צריך להגיש?

לפי ההוראות, צריך להגיש **3 קבצים**:
1. `docker-compose.producer.yml`
2. `docker-compose.consumer.yml`
3. `README.md`

**אבל** - ה-docker-compose files משתמשים ב-`build:` שצריך את הקוד כדי לבנות את ה-containers!

## פתרונות אפשריים:

### אפשרות 1: להגיש את כל ה-Solution (מומלץ) ✅

**מה להגיש:**
- כל התיקיות: `CartService/` ו-`OrderService/` (כולל הקוד)
- `docker-compose.producer.yml`
- `docker-compose.consumer.yml`
- `README.md`
- `CartService.sln` (אופציונלי)

**מה לא להגיש (נדחק אוטומטית עם .gitignore):**
- `bin/` ו-`obj/` (קבצי build)
- `.vs/`, `.vscode/` (קבצי IDE)
- קבצי cache שונים

**איך המרצה יריץ:**
```bash
docker-compose -f docker-compose.producer.yml up --build
docker-compose -f docker-compose.consumer.yml up --build
```

---

### אפשרות 2: להשתמש ב-Docker Images מוכנים

אם המרצה רוצה רק את ה-docker-compose files ללא הקוד, צריך:

1. **לבנות images ולהעלות ל-Docker Hub:**
```bash
# Build images
docker build -t yourusername/cartservice:latest ./CartService
docker build -t yourusername/orderservice:latest ./OrderService

# Push to Docker Hub
docker push yourusername/cartservice:latest
docker push yourusername/orderservice:latest
```

2. **לשנות את docker-compose files להשתמש ב-images:**
```yaml
# במקום build: CartService
image: yourusername/cartservice:latest
```

**אבל** - זה לא מה שההוראות ביקשו, והמרצה כנראה רוצה לראות את הקוד.

---

## המלצה: לשאול את המרצה! 🤔

**שאלות לשאול:**
1. האם צריך להגיש את כל ה-solution (כולל הקוד) או רק את ה-docker-compose files?
2. אם רק docker-compose - איך אמורים לבנות את ה-images?
3. האם צריך להעלות images ל-Docker Hub?

---

## מה אני ממליץ לעשות עכשיו:

### ✅ **הכי בטוח - להגיש את כל ה-Solution:**

**קבצים שצריך לכלול:**
```
📁 CartService/
  📁 Controllers/
  📁 Models/
  📁 Services/
  📁 Properties/
  📄 CartService.csproj
  📄 Program.cs
  📄 Dockerfile
  📄 appsettings.json
  📄 appsettings.Development.json

📁 OrderService/
  📁 Controllers/
  📁 Models/
  📁 Services/
  📁 Properties/
  📄 OrderService.csproj
  📄 Program.cs
  📄 Dockerfile
  📄 appsettings.json
  📄 appsettings.Development.json

📄 docker-compose.producer.yml
📄 docker-compose.consumer.yml
📄 README.md
📄 CartService.sln (אופציונלי)
```

**קבצים שלא צריך (נדחקים אוטומטית):**
- `bin/`, `obj/` - קבצי build
- `.vs/`, `.vscode/` - קבצי IDE
- קבצי cache

---

## איך לארוז להגשה:

### אם זה ZIP:
1. וודאי שיש `.gitignore` (כבר יצרתי)
2. צרי ZIP מהתיקייה הראשית
3. הקבצים המיותרים לא ייכללו

### אם זה Git:
```bash
git init
git add .
git commit -m "Submission"
# ואז שלחי את ה-repo
```

---

## סיכום:

**לפי ההוראות המקוריות** - צריך להגיש רק 3 קבצים, אבל זה לא יעבוד בלי הקוד.

**המלצה שלי:**
1. ✅ להגיש את כל ה-solution (כולל הקוד)
2. ✅ להוסיף הערה ב-README שהקוד נדרש ל-build
3. ✅ או לשאול את המרצה מה בדיוק הוא מצפה

**הכי בטוח - לשאול את המרצה לפני הגשה!** 📧

