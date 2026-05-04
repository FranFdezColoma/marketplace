# Power Automate Flow Patterns

## Pattern 1: Approval Flow

```
Trigger: Status → "Submitted"
  → Get approver from lookup/team
  → Start and wait for approval (set expiresOn)
  → Branch: Approved → update status, notify | Rejected → update, notify
```

Key: Use `msdyn_flow_approval` for trackability. Handle timeout. Support delegation. Log for audit.

---

## Pattern 2: Data Synchronization

```
Trigger: Scheduled (e.g., every 15 min)
  → Query records modified since last run
  → Apply to Each (with concurrency limit)
    → Transform → Call external API → Update sync status
  → Update last run timestamp
```

Key: Track last sync time (env var or custom table). Handle partial failures (continue on error). Summary notification with counts.

---

## Pattern 3: Notification

```
Trigger: Record event matching criteria
  → Determine recipients dynamically
  → Build content (adaptive card / email)
  → Send via channel
  → Log sent
```

| Channel | When | Connector |
|---------|------|-----------|
| Email (O365) | Formal, external recipients | Office 365 Outlook |
| Teams (Adaptive Card) | Internal, interactive | Microsoft Teams |
| Push | Mobile alerts | Power Apps Notification |

---

## Pattern 4: HTTP Webhook (Inbound Integration)

```
Trigger: HTTP request received
  → Validate payload schema
  → Authenticate (API key / token)
  → Transform → Create/Update Dataverse records
  → Respond 200/4xx/5xx
```

Security: Validate Authorization header, whitelist IPs, Secure Inputs, rate limit via APIM.

---

## Pattern 5: Child Flow Decomposition

```
Parent: Trigger → Call Child:Validate → Call Child:Process → Call Child:Notify
Child:  Input → Logic → Output (IsValid, ErrorMessage)
```

Rules: Single responsibility per child. Max ~30 actions/flow. Pass only needed data. Typed I/O. Solution-aware.

---

## Pattern 6: Retry and Recovery

```
Do Until: isSuccess OR retryCount >= maxRetries
  → HTTP call → 200? isSuccess=true : retryCount++, Delay(retryCount * 30s)

If still failed → Log permanent failure → Alert ops
```

Exponential backoff: `mul(30, outputs('retryCount'))`. Max 3-5 retries per SLA.

---

## Pattern 7: Scheduled Batch

```
Trigger: Recurrence (daily 2 AM)
  → Query with pagination ($top/$skip or @odata.nextLink)
  → Do Until: no more pages
    → Apply to Each (concurrency: 5) → process → update status
  → Send completion report
```

Key: Track progress for resume. Run off-peak. Monitor execution time (flow timeout: 30 days).
