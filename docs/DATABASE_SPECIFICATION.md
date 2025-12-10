# Database Specification for PulsePoll (MVP)

> **Note:** Fields marked with 🔮 are planned for post-MVP implementation.

---

## 1. Users

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | Integer | Primary Key, Auto-increment | Unique identifier |
| `email` | String | Unique, Not Null | User's email address |
| `password_digest` | String | Not Null | Hashed password (using bcrypt) |
| `first_name` | String | Not Null | User's first name |
| `last_name` | String | Not Null | User's last name |
| `created_at` | DateTime | Not Null | Record creation timestamp |
| `updated_at` | DateTime | Not Null | Record update timestamp |

---

## 2. Polls

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | Integer | Primary Key, Auto-increment | Unique identifier |
| `user_id` | Integer | Foreign Key (Users), Not Null | Poll creator reference |
| `question` | String | Not Null | The poll question |
| `public` | Boolean | Not Null, Default: true | Whether the poll appears in public browsing |
| `created_at` | DateTime | Not Null | Record creation timestamp |
| `updated_at` | DateTime | Not Null | Record update timestamp |

**Post-MVP Fields:** 🔮
- `secret_token`: String, Unique, Nullable - Generated when poll is made private for secure sharing
- `expires_at`: DateTime, Nullable - When the poll closes automatically

---

## 3. PollOptions

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | Integer | Primary Key, Auto-increment | Unique identifier |
| `poll_id` | Integer | Foreign Key (Polls), Not Null | Parent poll reference |
| `text` | String | Not Null | The option text |
| `created_at` | DateTime | Not Null | Record creation timestamp |
| `updated_at` | DateTime | Not Null | Record update timestamp |

---

## 4. Votes

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | Integer | Primary Key, Auto-increment | Unique identifier |
| `poll_option_id` | Integer | Foreign Key (PollOptions), Not Null | Selected option reference |
| `created_at` | DateTime | Not Null | Vote timestamp |

**Post-MVP Fields:** 🔮
- `user_id`: Integer, Nullable (Foreign Key to Users) - For tracking authenticated votes
- `voter_ip`: String, Nullable - For preventing duplicate anonymous votes

---

## Relationships

| Relationship | Type | Description |
|--------------|------|-------------|
| Users → Polls | One-to-Many | A user can create multiple polls; a poll belongs to one user |
| Polls → PollOptions | One-to-Many | A poll has multiple options; an option belongs to one poll |
| PollOptions → Votes | One-to-Many | An option can receive multiple votes; a vote is for one option |

**Post-MVP Relationships:** 🔮
- Users → Votes: One-to-Many, Optional (for tracking authenticated votes)

---

## MVP Considerations

- **Public/Private polls**: The `public` boolean controls whether a poll appears in the public browsing list. Private polls can still be accessed via their direct link.
- **No vote tracking** in MVP. Votes are anonymous and duplicate prevention is not enforced.
- **No expiration** in MVP. Polls remain open indefinitely.
- **`password_digest`** stores bcrypt-hashed passwords via Rails' `has_secure_password`.
- **Vote counts** are calculated via `COUNT` aggregation on the Votes table, not stored as a cached value.

---

## Database Indexes (Recommended)

```
users.email (unique)
polls.user_id
poll_options.poll_id
votes.poll_option_id
```

