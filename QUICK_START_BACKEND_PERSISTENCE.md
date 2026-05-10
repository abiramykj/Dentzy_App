# 🚀 Dentzy Backend Persistence - Quick Start Guide

## Setup & Verification (5 minutes)

### 1. Start MySQL Database
```bash
# Ensure MySQL is running
mysql -u root -p
# Enter password

# Verify database exists
mysql> SHOW DATABASES LIKE 'dentzy_db';
mysql> USE dentzy_db;
mysql> SHOW TABLES;
```

Expected tables:
- users
- myth_history
- brushing_tracker
- notifications
- otp_verification
- token_blacklist

### 2. Start Backend Server
```bash
cd c:\Users\Dyuthi\Dentzy_App
# Activate virtual environment
.\.venv\Scripts\Activate.ps1

# Navigate to backend
cd backend

# Start server with logging
python -m uvicorn main:app --host 0.0.0.0 --port 8080 --reload --log-level=info
```

Expected output:
```
INFO:     Uvicorn running on http://0.0.0.0:8080
INFO:     Application startup complete
[TIMESTAMP] Backend starting - Multilingual Myth Checker
[TIMESTAMP] Groq model=llama-3.3-70b-versatile
[TIMESTAMP] GROQ API key loaded=True
```

### 3. Run Persistence Tests
In a new terminal:
```bash
cd c:\Users\Dyuthi\Dentzy_App

# Run the comprehensive test suite
python test_backend_persistence.py
```

Expected output:
```
════════════════════════════════════════════════════════════════════════
    DENTZY BACKEND PERSISTENCE TEST SUITE
════════════════════════════════════════════════════════════════════════

Backend URL: http://127.0.0.1:8080
Test User: test_user_<timestamp>@example.com

✅ SIGNUP - User created with ID 42
✅ LOGIN - User authenticated
✅ MYTH CHECKING - Type: FACT, Confidence: 95
✅ MYTH SAVE - Saved to myth_history (ID: 156)
✅ FETCH MYTH HISTORY - Retrieved 5 records
✅ BRUSHING SAVE - Saved for 2024-05-10
✅ BRUSHING FETCH - Retrieved 10 records
✅ NOTIFICATION SAVE - Notification settings saved
✅ NOTIFICATION FETCH - Settings retrieved

📊 Results: 8/8 tests passed
🎉 All tests passed! Backend persistence is working correctly.
```

### 4. Verify Data in MySQL
```bash
mysql -u root -p dentzy_db

# Check users created
mysql> SELECT id, email, username, created_at FROM users ORDER BY created_at DESC LIMIT 5;

# Check myth history
mysql> SELECT id, user_id, statement, result_type, confidence FROM myth_history ORDER BY timestamp DESC LIMIT 5;

# Check brushing records
mysql> SELECT id, user_id, date, morning_brushed, night_brushed, streak FROM brushing_tracker ORDER BY date DESC LIMIT 5;

# Check notifications
mysql> SELECT id, user_id, reminder_time, enabled FROM notifications;
```

---

## Flutter App Integration (20 minutes)

### Step 1: Build & Run Flutter App
```bash
cd c:\Users\Dyuthi\Dentzy_App\dentzy

# Build APK for testing
flutter build apk

# Or run directly on emulator
flutter run
```

### Step 2: Create Test Account
1. Open app on device/emulator
2. Go to Sign Up screen
3. Enter:
   - **Email:** test@example.com
   - **Password:** Test@123
   - **Username:** Test User
   - **Language:** English

Expected: Account created, logged in automatically

### Step 3: Test Myth Checking
1. Tap **Myth Checker** from home
2. Enter: `"Is brushing teeth immediately after eating acidic foods good?"`
3. Tap **Check Statement**
4. Expected result: 
   - **Type:** MYTH
   - **Confidence:** 95%
   - **Explanation:** [Explanation about waiting 30-60 minutes]
5. Data saved to `myth_history` table ✓

### Step 4: Test Brushing Tracker
1. Tap **Brushing Tracker** from home
2. Select a family member
3. Tap **Mark Morning** - Should turn green ✓
4. Tap **Mark Night** - Should turn green ✓
5. Data saved to `brushing_tracker` table ✓

### Step 5: View History
1. Go to **Profile** → **Health Analytics**
2. View **Myth History** - Should show your checks
3. View **Brushing Stats** - Should show your logs

---

## Debugging & Logs

### View Backend Logs
While backend is running, you'll see logs like:
```
[TIMESTAMP] [DATABASE] User inserted into MySQL user_id=42 email=test@example.com
[TIMESTAMP] [API] POST /api/myths/history user_id=42 statement_len=50 type=MYTH
[TIMESTAMP] [DATABASE] Insert success - myth history saved user_id=42 entry_id=156
[TIMESTAMP] [API] POST /api/brushing/records user_id=42 date=2024-05-10
[TIMESTAMP] [DATABASE] Insert success - brushing tracker saved user_id=42 date=2024-05-10
```

### Check Flutter Debug Output
```bash
# In VS Code terminal or Android Studio
flutter logs

# Expected output when myth is saved:
I/flutter ( 5432): [MythApiService] POST http://10.0.2.2:8080/classify
I/flutter ( 5432): [API] Myth history saved
I/flutter ( 5432): [BrushingApiService] POST http://10.0.2.2:8080/api/brushing/records
I/flutter ( 5432): [API] Brushing tracker saved
```

### Troubleshooting

**Issue: Backend returns 401 (Unauthorized)**
- Cause: Token expired or missing
- Solution: Log out and log back in

**Issue: 400 Bad Request on myth save**
- Cause: Missing auth token
- Solution: Ensure user is logged in before checking myths

**Issue: 500 Internal Server Error**
- Check backend logs for specific error
- Verify MySQL connection: `mysql -u root -p dentzy_db`
- Check database tables exist: `SHOW TABLES;`

---

## API Endpoints Reference

### Authentication
```
POST /signup
  Body: {email, password, username, selected_language, remember_me}
  Response: {success, access_token, user}

POST /login
  Body: {email, password, remember_me}
  Response: {success, access_token, user}

POST /send-otp
  Body: {email}
  Response: {success, message}

POST /verify-otp
  Body: {email, otp}
  Response: {success, message}
```

### Myth Checking
```
POST /classify
  Body: {text}
  Response: {type, confidence, explanation}

POST /api/myths/history
  Headers: Authorization: Bearer <token>
  Body: {statement, result_type, confidence, explanation}
  Response: {id, user_id, statement, result_type, confidence, explanation, timestamp}

GET /api/myths/history
  Headers: Authorization: Bearer <token>
  Response: [{id, user_id, statement, result_type, confidence, explanation, timestamp}, ...]

DELETE /api/myths/history/{history_id}
  Headers: Authorization: Bearer <token>
  Response: {success, message}
```

### Brushing Tracker
```
POST /api/brushing/records
  Headers: Authorization: Bearer <token>
  Body: {date, morning_brushed, night_brushed, streak}
  Response: {id, user_id, date, morning_brushed, night_brushed, streak}

GET /api/brushing/records
  Headers: Authorization: Bearer <token>
  Response: [{id, user_id, date, morning_brushed, night_brushed, streak}, ...]

PUT /api/brushing/records/{date}
  Headers: Authorization: Bearer <token>
  Body: {morning_brushed?, night_brushed?, streak?}
  Response: {id, user_id, date, morning_brushed, night_brushed, streak}
```

### Notifications
```
POST /api/notifications/me
  Headers: Authorization: Bearer <token>
  Body: {reminder_time, enabled}
  Response: {id, user_id, reminder_time, enabled}

GET /api/notifications/me
  Headers: Authorization: Bearer <token>
  Response: {id, user_id, reminder_time, enabled}

PUT /api/notifications/me
  Headers: Authorization: Bearer <token>
  Body: {reminder_time?, enabled?}
  Response: {id, user_id, reminder_time, enabled}
```

---

## Performance Metrics

### Expected Response Times
- Myth Classification: 300-500ms (via GROQ API)
- Myth History Save: 50-100ms
- Brushing Save: 50-100ms
- Fetch History: 30-50ms

### Database Indexes
Automatically created on:
- users.email (UNIQUE)
- myth_history.user_id
- myth_history.timestamp
- brushing_tracker.user_id
- brushing_tracker.date
- notifications.user_id
- otp_verification.email

---

## Security Features

✅ **Implemented:**
- Bcrypt password hashing
- JWT token authentication
- Foreign key constraints
- SQL injection protection (SQLAlchemy)
- CORS enabled
- Bearer token validation

⚠️ **Future Enhancement:**
- Rate limiting (10 requests/minute)
- API key authentication
- HTTPS/TLS
- Request signing
- Audit logging

---

## Database Backup

### Create Backup
```bash
mysqldump -u root -p dentzy_db > dentzy_db_backup.sql
```

### Restore Backup
```bash
mysql -u root -p dentzy_db < dentzy_db_backup.sql
```

---

## Monitoring

### Check Database Size
```bash
mysql> SELECT 
  table_name,
  ROUND(((data_length + index_length) / 1024 / 1024), 2) AS size_mb
FROM information_schema.tables
WHERE table_schema = 'dentzy_db'
ORDER BY (data_length + index_length) DESC;
```

### Check Record Counts
```bash
mysql> SELECT 
  'users' as table_name, COUNT(*) as count FROM users
UNION ALL SELECT 'myth_history', COUNT(*) FROM myth_history
UNION ALL SELECT 'brushing_tracker', COUNT(*) FROM brushing_tracker
UNION ALL SELECT 'notifications', COUNT(*) FROM notifications
UNION ALL SELECT 'otp_verification', COUNT(*) FROM otp_verification;
```

---

## Success Indicators ✅

After following this guide, you should see:

1. ✅ Test script runs successfully (8/8 tests pass)
2. ✅ Flutter app saves myth checks to database
3. ✅ Flutter app saves brushing records to database
4. ✅ Notification settings persist in database
5. ✅ Backend logs show [DATABASE] Insert success messages
6. ✅ MySQL queries return real app data
7. ✅ Data survives app restarts (no local storage fallback)

---

## Next Steps

1. **Deploy Backend**
   - Use production-grade server (Gunicorn, uWSGI)
   - Add load balancer
   - Setup SSL/TLS

2. **Production Database**
   - Create read replicas
   - Setup automated backups
   - Configure monitoring

3. **App Store Release**
   - Update API endpoint to production URL
   - Remove debug logging
   - Add analytics tracking

---

## Support

For issues:
1. Check [BACKEND_PERSISTENCE_IMPLEMENTATION.md](BACKEND_PERSISTENCE_IMPLEMENTATION.md)
2. Review backend logs for error details
3. Verify MySQL tables exist
4. Run test suite to isolate issue

---

**You now have a fully functional backend-powered Dentzy app! 🎉**
