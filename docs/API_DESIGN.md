# API Design for PulsePoll (MVP)

All API endpoints are prefixed with `/api`.

> **Note:** Endpoints marked with 🔮 are planned for post-MVP implementation.

---

## Endpoint Overview

| Resource | Endpoints |
|----------|-----------|
| Authentication | `/api/auth/**` |
| Polls | `/api/polls/**` |
| User Polls | `/api/users/polls/**` |

---

## Authentication Endpoints

### 1. Register

**Endpoint:** `POST /api/auth/register`

**Description:** Creates a new user account.

**Request Body:**

```json
{
  "first_name": "John",
  "last_name": "Doe",
  "email": "user@example.com",
  "password": "securepassword123"
}
```

**Success Response:** `201 Created`

```json
{
  "message": "User created successfully",
  "user_id": 1,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Error Responses:**

| Code | Condition | Response |
|------|-----------|----------|
| 400 | Email already in use | `{ "error": "Email already in use" }` |
| 422 | Missing required fields | `{ "error": "Email, password, first_name, and last_name are required" }` |

**Considerations:**
- Validate email format and password strength
- Passwords are hashed with bcrypt before storage
- Returns JWT token on successful registration (user is logged in immediately)

---

### 2. Login

**Endpoint:** `POST /api/auth/login`

**Description:** Authenticates a user and returns a JWT token.

**Request Body:**

```json
{
  "email": "user@example.com",
  "password": "securepassword123"
}
```

**Success Response:** `200 OK`

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user_id": 1
}
```

**Error Responses:**

| Code | Condition | Response |
|------|-----------|----------|
| 401 | Invalid credentials | `{ "error": "Invalid email or password" }` |

**Considerations:**
- Token is a JWT used in the `Authorization` header for authenticated requests
- Use HTTPS in production to secure credential transmission

---

### 3. Logout

**Endpoint:** `POST /api/auth/logout`

**Description:** Logs out the current user.

**Headers:**

```
Authorization: Bearer <token>
```

**Success Response:** `200 OK`

```json
{
  "message": "User logged out successfully"
}
```

**MVP Consideration:**
- For MVP, logout is handled client-side by deleting the stored token
- The endpoint exists for API completeness but JWT remains valid until expiration

**Post-MVP Consideration:** 🔮
- Implement token blacklisting for true server-side logout

---

## Polls Endpoints

### 1. Create Poll

**Endpoint:** `POST /api/polls`

**Description:** Creates a new poll with options. Requires authentication.

**Headers:**

```
Authorization: Bearer <token>
```

**Request Body:**

```json
{
  "question": "What's your favorite programming language?",
  "options": ["Python", "JavaScript", "Ruby", "Java"],
  "public": true
}
```

**Constraints:**
- `options` must have between 2 and 10 items
- `public` defaults to `true` if not provided

**Success Response:** `201 Created`

```json
{
  "id": 1,
  "message": "Poll created successfully"
}
```

**Error Responses:**

| Code | Condition | Response |
|------|-----------|----------|
| 401 | Missing/invalid token | `{ "error": "Unauthorized" }` |
| 422 | Invalid input | `{ "error": "Question is required and options must have 2-10 items" }` |

---

### 2. Get Public Polls

**Endpoint:** `GET /api/polls`

**Description:** Returns a list of all public polls for the landing page.

**Success Response:** `200 OK`

```json
[
  {
    "id": 1,
    "question": "What's your favorite programming language?",
    "total_votes": 20
  },
  {
    "id": 2,
    "question": "Best frontend framework?",
    "total_votes": 15
  }
]
```

**Notes:**
- Only returns polls where `public = true`
- Includes total vote count for each poll

---

### 3. Get Poll by ID

**Endpoint:** `GET /api/polls/:id`

**Description:** Returns poll details including options and vote counts.

**Success Response:** `200 OK`

```json
{
  "id": 1,
  "question": "What's your favorite programming language?",
  "user_id": 5,
  "public": true,
  "options": [
    { "id": 1, "text": "Python", "votes_count": 10 },
    { "id": 2, "text": "JavaScript", "votes_count": 5 },
    { "id": 3, "text": "Ruby", "votes_count": 3 },
    { "id": 4, "text": "Java", "votes_count": 2 }
  ]
}
```

**Error Responses:**

| Code | Condition | Response |
|------|-----------|----------|
| 404 | Poll not found | `{ "error": "Poll not found" }` |

**Notes:**
- Both public and private polls are accessible via their ID
- Private polls simply don't appear in the public listing

---

### 4. Submit Vote

**Endpoint:** `POST /api/polls/:poll_id/vote`

**Description:** Submits a vote for a specific option. No authentication required.

**Request Body:**

```json
{
  "poll_option_id": 2
}
```

**Success Response:** `201 Created`

```json
{
  "message": "Vote cast successfully"
}
```

**Error Responses:**

| Code | Condition | Response |
|------|-----------|----------|
| 404 | Poll not found | `{ "error": "Poll not found" }` |
| 400 | Invalid option | `{ "error": "Invalid option for this poll" }` |

**MVP Notes:**
- No duplicate vote prevention in MVP
- Votes are anonymous (no user tracking)

**Post-MVP Considerations:** 🔮
- Duplicate vote prevention via IP/cookies
- Poll expiration check

---

## User Polls Endpoints

All endpoints in this section require authentication.

### 1. Get My Polls

**Endpoint:** `GET /api/users/polls`

**Description:** Returns all polls created by the authenticated user.

**Headers:**

```
Authorization: Bearer <token>
```

**Success Response:** `200 OK`

```json
[
  {
    "id": 1,
    "question": "What's your favorite programming language?",
    "public": true,
    "total_votes": 20,
    "created_at": "2024-01-15T10:30:00Z"
  },
  {
    "id": 3,
    "question": "Team lunch preference?",
    "public": false,
    "total_votes": 8,
    "created_at": "2024-01-14T09:00:00Z"
  }
]
```

**Error Responses:**

| Code | Condition | Response |
|------|-----------|----------|
| 401 | Unauthorized | `{ "error": "Unauthorized" }` |

---

## Post-MVP Endpoints 🔮

The following endpoints are planned for future releases:

### Polls

| Method | Endpoint | Description |
|--------|----------|-------------|
| `PUT` | `/api/polls/:id` | Update poll question, options, or visibility |
| `DELETE` | `/api/polls/:id` | Delete a poll |
| `GET` | `/api/polls/private/:secret_token` | Access private poll via secret token |

### User Polls

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/users/polls/:id` | Get detailed poll analytics for owner |
| `DELETE` | `/api/users/polls/:id` | Delete a user's poll |
| `DELETE` | `/api/users/polls` | Batch delete multiple polls |

---

## Common Response Patterns

### Authentication Errors

All protected endpoints return:

```json
{
  "error": "Unauthorized"
}
```

With status code `401` when the token is missing, invalid, or expired.

### Validation Errors

Invalid request data returns status `422` with:

```json
{
  "error": "Description of what's invalid"
}
```

---

## Authentication

Protected endpoints require the JWT token in the Authorization header:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

