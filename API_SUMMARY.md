# SaSu Family Backend - API Summary

## Overview
Family financial management system with role-based access control (ADMIN and FAMILY roles).

---

## 1. Authentication APIs (`/api/auth`)

| Endpoint | Method | Access | Description |
|----------|--------|--------|-------------|
| `/api/auth/login` | POST | Public | User login - returns JWT token |
| `/api/auth/register` | POST | Public | New user registration |

---

## 2. Assets APIs (`/api/assets`)

| Endpoint | Method | Access | Description |
|----------|--------|--------|-------------|
| `/api/assets` | GET | ADMIN, FAMILY | Get all assets |
| `/api/assets/{id}` | GET | ADMIN, FAMILY | Get asset by ID |
| `/api/assets` | POST | ADMIN only | Create new asset |
| `/api/assets/{id}` | PUT | ADMIN only | Update asset |
| `/api/assets/{id}` | DELETE | ADMIN only | Delete asset |

---

## 3. Insurance APIs (`/api/insurance`)

| Endpoint | Method | Access | Description |
|----------|--------|--------|-------------|
| `/api/insurance` | GET | ADMIN, FAMILY | Get all insurance policies |
| `/api/insurance/{id}` | GET | ADMIN, FAMILY | Get insurance by ID |
| `/api/insurance` | POST | ADMIN only | Create new insurance |
| `/api/insurance/{id}` | PUT | ADMIN only | Update insurance |
| `/api/insurance/{id}` | DELETE | ADMIN only | Delete insurance |

---

## 4. Liabilities APIs (`/api/liabilities`)

| Endpoint | Method | Access | Description |
|----------|--------|--------|-------------|
| `/api/liabilities` | GET | ADMIN, FAMILY | Get all liabilities |
| `/api/liabilities/{id}` | GET | ADMIN, FAMILY | Get liability by ID |
| `/api/liabilities` | POST | ADMIN only | Create new liability |
| `/api/liabilities/{id}` | PUT | ADMIN only | Update liability |
| `/api/liabilities/{id}` | DELETE | ADMIN only | Delete liability |

---

## 5. Dashboard APIs (`/api/dashboard`)

| Endpoint | Method | Access | Description |
|----------|--------|--------|-------------|
| `/api/dashboard/summary` | GET | ADMIN, FAMILY | Get financial health overview |

---

## 6. Future Projections APIs (`/api/future`)

| Endpoint | Method | Access | Description |
|----------|--------|--------|-------------|
| `/api/future/projections?currentAge={age}` | GET | ADMIN, FAMILY | Get year-wise future benefits (default age: 35) |

---

## Access Control Summary

- **ADMIN**: Full CRUD access to all resources
- **FAMILY**: Read-only access (GET operations only)
- **Public**: Login and registration only

## Security

- JWT-based authentication
- Role-based authorization using `@PreAuthorize` annotations
- Password encryption

---

## Total Endpoints: 20

- **Authentication**: 2 endpoints
- **Assets**: 5 endpoints (2 read, 3 write)
- **Insurance**: 5 endpoints (2 read, 3 write)
- **Liabilities**: 5 endpoints (2 read, 3 write)
- **Dashboard**: 1 endpoint (read-only)
- **Future Projections**: 1 endpoint (read-only)

## Recommendations for Code Cleanup

1. **Consolidate CRUD patterns** - Consider creating a base controller/service for common CRUD operations
2. **Standardize response formats** - Use consistent DTO response objects instead of raw entities
3. **Error handling** - Implement global exception handler for consistent error responses
4. **API versioning** - Consider adding `/v1/` to API paths for future versioning
5. **Pagination** - Add pagination support to list endpoints (GET all operations)
6. **Input validation** - Add `@Valid` annotations for request body validation
7. **API documentation** - Add Swagger/OpenAPI for auto-generated documentation

