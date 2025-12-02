# מדריך הגשה עם Docker Hub - שלב אחר שלב

## 📋 מה צריך לעשות:

1. ✅ יצירת חשבון Docker Hub
2. ✅ בניית Images מהקוד
3. ✅ העלאת Images ל-Docker Hub
4. ✅ עדכון docker-compose files
5. ✅ בדיקה שהכל עובד
6. ✅ הגשת הקבצים

---

## שלב 1: יצירת חשבון Docker Hub

1. היכנסי ל: **https://hub.docker.com**
2. לחצי על **"Sign Up"** (אם אין לך חשבון)
3. מלאי את הפרטים ויצרי חשבון
4. **זכרי את שם המשתמש שלך!** (לדוגמה: `stavglam`)

---

## שלב 2: התחברות ל-Docker Hub מהטרמינל

פתחי PowerShell או Terminal והרצי:

```bash
docker login
```

הכנסי:
- **Username:** שם המשתמש שלך ב-Docker Hub
- **Password:** הסיסמה שלך

**תוצאה צפויה:** `Login Succeeded`

---

## שלב 3: בניית והעלאת Images

### אופציה A: שימוש בסקריפט האוטומטי (מומלץ) ⚡

**Windows (PowerShell):**
```powershell
.\build-and-push.ps1 YOUR_DOCKER_USERNAME
```

**Linux/Mac (Bash):**
```bash
chmod +x build-and-push.sh
./build-and-push.sh YOUR_DOCKER_USERNAME
```

**דוגמה:**
```powershell
.\build-and-push.ps1 stavglam
```

הסקריפט יעשה הכל אוטומטית:
- ✅ יבנה את שני ה-images
- ✅ יעלה אותם ל-Docker Hub
- ✅ יעדכן את ה-docker-compose files

---

### אופציה B: ידנית (אם הסקריפט לא עובד)

#### 3.1 בניית CartService Image:
```bash
docker build -t YOUR_USERNAME/cartservice:latest ./CartService
```

**החלפי `YOUR_USERNAME` בשם המשתמש שלך!**

**דוגמה:**
```bash
docker build -t stavglam/cartservice:latest ./CartService
```

#### 3.2 בניית OrderService Image:
```bash
docker build -t YOUR_USERNAME/orderservice:latest ./OrderService
```

**דוגמה:**
```bash
docker build -t stavglam/orderservice:latest ./OrderService
```

#### 3.3 העלאת CartService ל-Docker Hub:
```bash
docker push YOUR_USERNAME/cartservice:latest
```

**דוגמה:**
```bash
docker push stavglam/cartservice:latest
```

#### 3.4 העלאת OrderService ל-Docker Hub:
```bash
docker push YOUR_USERNAME/orderservice:latest
```

**דוגמה:**
```bash
docker push stavglam/orderservice:latest
```

**הערה:** זה יכול לקחת כמה דקות, תלוי בגודל ה-images.

---

## שלב 4: עדכון docker-compose files

### אם השתמשת בסקריפט:
✅ הקבצים כבר עודכנו אוטומטית!

### אם עשית ידנית:
צריך לעדכן את הקבצים:

**docker-compose.producer.yml:**
```yaml
cartservice:
  image: YOUR_USERNAME/cartservice:latest  # החלפי YOUR_USERNAME
```

**docker-compose.consumer.yml:**
```yaml
orderservice:
  image: YOUR_USERNAME/orderservice:latest  # החלפי YOUR_USERNAME
```

**דוגמה:**
```yaml
cartservice:
  image: stavglam/cartservice:latest
```

---

## שלב 5: בדיקה שהכל עובד

### 5.1 בדיקה שה-images קיימים ב-Docker Hub:

1. היכנסי ל: **https://hub.docker.com**
2. לחצי על שם המשתמש שלך
3. ודאי שיש לך 2 repositories:
   - `cartservice`
   - `orderservice`

### 5.2 בדיקה מקומית:

**Producer:**
```bash
docker-compose -f docker-compose.producer.yml up
```

**Consumer (בטרמינל אחר):**
```bash
docker-compose -f docker-compose.consumer.yml up
```

**וודאי שהכל עובד:**
- ✅ CartService: http://localhost:8080/swagger
- ✅ OrderService: http://localhost:8081/swagger

### 5.3 בדיקה שה-images Public:

1. היכנסי לכל repository ב-Docker Hub
2. ודאי שהסטטוס הוא **"Public"** (לא Private)
3. אם זה Private, המרצה לא יוכל להוריד!

**איך לשנות ל-Public:**
- Settings → Visibility → Public

---

## שלב 6: הגשת הקבצים

### מה להגיש:

📦 **רק 3 קבצים:**

1. ✅ `docker-compose.producer.yml`
   - ודאי שהשם שלך מופיע (לא `YOUR_USERNAME`)

2. ✅ `docker-compose.consumer.yml`
   - ודאי שהשם שלך מופיע (לא `YOUR_USERNAME`)

3. ✅ `README.md`
   - מלאי את הפרטים האישיים (שם ומספר תעודת זהות)

### איך לארוז:

**אם זה ZIP:**
1. בחרי את 3 הקבצים
2. צרי ZIP
3. שלחי

**אם זה Git:**
```bash
git add docker-compose.producer.yml docker-compose.consumer.yml README.md
git commit -m "Submission"
git push
```

---

## ✅ סיכום - Checklist לפני הגשה:

- [ ] חשבון Docker Hub נוצר
- [ ] התחברתי: `docker login`
- [ ] בניתי images: `docker build -t ...`
- [ ] העליתי images: `docker push ...`
- [ ] Images קיימים ב-Docker Hub
- [ ] Images הם Public
- [ ] עדכנתי docker-compose files (או השתמשתי בסקריפט)
- [ ] בדקתי שהכל עובד מקומית
- [ ] מלאתי את הפרטים האישיים ב-README.md
- [ ] ודאתי שהשם ב-docker-compose תואם לשם ב-Docker Hub

---

## 🆘 פתרון בעיות:

### בעיה: "unauthorized: authentication required"
**פתרון:** הרצי `docker login` שוב

### בעיה: "repository does not exist"
**פתרון:** ודאי שהשם נכון: `username/repository-name`

### בעיה: "denied: requested access to the resource is denied"
**פתרון:** ודאי שה-repository הוא Public

### בעיה: המרצה לא יכול להוריד
**פתרון:** 
1. ודאי שה-images הם Public
2. ודאי שהשם ב-docker-compose תואם לשם ב-Docker Hub
3. בדקי שהמרצה יכול לראות את ה-repositories ב-Docker Hub

---

## 📝 דוגמה מלאה:

**אם שם המשתמש שלך הוא `stavglam`:**

1. **בנייה:**
```bash
docker build -t stavglam/cartservice:latest ./CartService
docker build -t stavglam/orderservice:latest ./OrderService
```

2. **העלאה:**
```bash
docker push stavglam/cartservice:latest
docker push stavglam/orderservice:latest
```

3. **docker-compose.producer.yml:**
```yaml
cartservice:
  image: stavglam/cartservice:latest
```

4. **docker-compose.consumer.yml:**
```yaml
orderservice:
  image: stavglam/orderservice:latest
```

---

## 🎯 מה המרצה צריך לעשות:

המרצה פשוט יריץ:

```bash
docker-compose -f docker-compose.producer.yml up
docker-compose -f docker-compose.consumer.yml up
```

Docker יוריד אוטומטית את ה-images מ-Docker Hub! 🚀

---

**בהצלחה!** 🎉

