# 🏡 SaSu Family Wealth Dashboard - Backend

## Overview
**SaSu** is a Family Wealth & Future Readiness Dashboard designed for family financial planning.

### Purpose
- **Admin (Father)**: Full CRUD access to manage financial data
- **Family (Wife, Daughter)**: Read-only access to view financial health
- **Focus**: Calm, motivating, confidence-building financial overview

---

## 🚀 Quick Start

### Prerequisites
- Java 17+
- Maven 3.6+

### Run the Application
```bash
cd sasu-backend
mvn clean install
mvn spring-boot:run
```

The backend will start at: **http://localhost:8080**

---

## 👥 Default Users

| Username | Password | Role | Access |
|----------|----------|------|--------|
| admin | admin123 | ADMIN | Full CRUD access |
| wife | wife123 | FAMILY | Read-only |
| daughter | daughter123 | FAMILY | Read-only |

---

## 📡 API Endpoints

### Authentication
- **POST** `/api/auth/login` - Login
- **POST** `/api/auth/register` - Register new user (admin only in production)

### Dashboard
- **GET** `/api/dashboard/summary` - Get complete dashboard overview

### Assets (ADMIN: Full access, FAMILY: Read-only)
- **GET** `/api/assets` - Get all assets
- **GET** `/api/assets/{id}` - Get asset by ID
- **POST** `/api/assets` - Create asset (ADMIN only)
- **PUT** `/api/assets/{id}` - Update asset (ADMIN only)
- **DELETE** `/api/assets/{id}` - Delete asset (ADMIN only)

### Insurance (ADMIN: Full access, FAMILY: Read-only)
- **GET** `/api/insurance` - Get all insurance policies
- **GET** `/api/insurance/{id}` - Get insurance by ID
- **POST** `/api/insurance` - Create insurance (ADMIN only)
- **PUT** `/api/insurance/{id}` - Update insurance (ADMIN only)
- **DELETE** `/api/insurance/{id}` - Delete insurance (ADMIN only)

### Liabilities (ADMIN: Full access, FAMILY: Read-only)
- **GET** `/api/liabilities` - Get all liabilities
- **GET** `/api/liabilities/{id}` - Get liability by ID
- **POST** `/api/liabilities` - Create liability (ADMIN only)
- **PUT** `/api/liabilities/{id}` - Update liability (ADMIN only)
- **DELETE** `/api/liabilities/{id}` - Delete liability (ADMIN only)

### Future Projections
- **GET** `/api/future/projections?currentAge=35` - Get year-wise future projections

---

## 🏗️ Architecture

### Models
- **User** - Family members with roles (ADMIN/FAMILY)
- **Asset** - Land, house, EPF, savings, etc.
- **Insurance** - Life, medical, education plans
- **Liability** - Loans and credits

### Key Features
1. **Wealth Health Score** (0-100) - Calculated based on:
   - Total assets
   - Total liabilities
   - Insurance coverage
   
2. **Future Projections** - Year-wise projections showing:
   - Asset growth
   - Insurance maturity
   - Retirement readiness

3. **Role-Based Access**:
   - ADMIN: Full CRUD
   - FAMILY: Read-only

---

## 🔐 Security
- JWT-based authentication
- Role-based authorization
- Secure password encryption (BCrypt)
- CORS enabled for mobile app integration

---

## 💾 Database
- SQLite (for easy deployment)
- Auto-creates `sasu_family.db` on first run
- Sample data auto-initialized

---

## 📊 Sample Data Included
- 5 Assets (Land, House, EPF, FD, Savings)
- 3 Insurance Policies (Life, Medical, Education)
- 2 Liabilities (Home Loan, Car Loan)
- 3 Users (admin, wife, daughter)

---

## 🛠️ Technology Stack
- Spring Boot 3.2.0
- Spring Security
- Spring Data JPA
- SQLite Database
- JWT Authentication
- Lombok
- Maven

---

## 📱 Mobile App Integration
The backend is designed to work seamlessly with the Flutter mobile app.

### API Usage Example
```bash
# 1. Login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'

# Response:
# {
#   "token": "eyJhbGc...",
#   "username": "admin",
#   "fullName": "Father (Admin)",
#   "role": "ADMIN"
# }

# 2. Get Dashboard (use token from login)
curl -X GET http://localhost:8080/api/dashboard/summary \
  -H "Authorization: Bearer eyJhbGc..."

# Response:
# {
#   "totalAssets": 52500000,
#   "totalLiabilities": 7200000,
#   "netWorth": 45300000,
#   "wealthHealthScore": 85,
#   "wealthHealthLabel": "Excellent",
#   "motivationalMessage": "Your family is financially strong..."
# }
```

---

## 📝 Notes
- All monetary values are in your local currency
- Dates are in ISO format (YYYY-MM-DD)
- All endpoints (except /api/auth/**) require authentication
- ADMIN role required for create/update/delete operations

---

## 🎯 Next Steps
1. Run the backend
2. Test APIs using Postman or curl
3. Connect Flutter mobile app
4. Customize motivational messages
5. Add more family members if needed

---

## 🤝 Support
For issues or questions, check the logs in the console.

**Built with ❤️ for your family's financial future**

