# New Admin Endpoints Added

## Auth
- `POST /api/admin/refresh-token`
- `GET /api/admin/me`

## Requests
- `GET /api/admin/requests/:id/timeline`
- `PUT /api/admin/requests/:id/close` — body `{ status: "closed" | "canceled", note? }`

## Complaints / Support
- `GET /api/admin/complaints?status=&page=&perPage=`
- `GET /api/admin/complaints/:id`
- `PUT /api/admin/complaints/:id/status` — body `{ status: "open" | "assigned" | "resolved" | "closed" }`
- `PUT /api/admin/complaints/:id/assign` — body `{ agentId }`
- `POST /api/admin/complaints/:id/messages` — body `{ message, attachments? }`

## Settings
- `GET /api/admin/settings/general`
- `PUT /api/admin/settings/general` — body `{ appName?, supportEmail?, about?, logoUrl? }`
- `POST /api/admin/uploads/logo` — multipart field `logo` → `{ data: { url } }`

## Notifications Templates
- `GET /api/admin/notifications/templates`
- `POST /api/admin/notifications/templates` — body `{ name, target?, title, message }`
- `PUT /api/admin/notifications/templates/:id` — body `{ name?, target?, title?, message? }`
- `DELETE /api/admin/notifications/templates/:id`

## Marketing
- `GET /api/admin/marketing/coupons?page=&perPage=`
- `POST /api/admin/marketing/coupons` — body `{ code, value, discountType?, minOrder?, expiresAt?, active? }`
- `PUT /api/admin/marketing/coupons/:id` — same shape as create, all optional
- `DELETE /api/admin/marketing/coupons/:id`
- `GET /api/admin/marketing/referral`
- `GET /api/admin/marketing/rewards`

## Logs
- `GET /api/admin/logs/activity?page=&perPage=`
- `GET /api/admin/logs/health`

## Roles & Permissions
- `GET /api/admin/roles`
- `GET /api/admin/roles/:id`
- `POST /api/admin/roles` — body `{ name, description?, permissions? }`
- `PUT /api/admin/roles/:id` — body `{ name?, description?, permissions? }`
- `DELETE /api/admin/roles/:id`

## Orders / Wallet / Payouts
- `GET /api/admin/orders?status=&page=&perPage=`
- `GET /api/admin/orders/:id`
- `GET /api/admin/orders/:id/timeline`
- `GET /api/admin/wallets`
- `GET /api/admin/payouts/:id`
- `PUT /api/admin/payouts/:id/status` — body `{ status }`

## AI / Analytics Extras
- `GET /api/admin/ai/word-cloud`

## Envelope
- New endpoints return `{ data: ... }` or `{ data, pagination: { total, page, perPage } }` with ISO date strings and `{ message, code, error, details }` on errors.
