# Dataverse Design Patterns

## Relationship Modeling

### 1:N Relationships

| Cascade Behavior | When |
|-----------------|------|
| RemoveLink | Optional relationship (child survives without parent) |
| Cascade (Parental) | Strong ownership (child deleted with parent) |
| Referential | Child can exist independently |

### N:N Relationships

| Pattern | When |
|---------|------|
| Native N:N | Simple association, no data on the relationship |
| Manual intersect entity | Need attributes on relationship (dates, roles) |

### Polymorphic Lookups
- Customer lookup (Account OR Contact) — built-in
- Regarding lookup (Activities) — built-in
- Custom: use Customer type or multiple lookup columns

### Self-Referential
- Use for hierarchical data (org charts, categories, territories)
- Enable hierarchy visualization; use calculated/rollup fields through hierarchy

---

## Alternate Keys

**Use for**: integration (external ID matching), Upsert operations, platform-level duplicate prevention.

Rules:
- Max 5 columns per key
- Supported types: String, Integer, Decimal, Lookup, DateTime, OptionSet
- Consider index performance impact
- Name: `contoso_externalid_key`

---

## Calculated vs. Rollup Fields

| Calculated | Rollup |
|-----------|--------|
| Value from same record | Aggregates child records |
| Real-time | Updated every 12h (or on-demand via `CalculateRollupField`) |
| Full Name = First + Last | Total Invoice Amount |
| Days Until Due = Due - Today | Count Open Cases |

Rollup constraints: max 100 per entity; cannot reference other rollup fields.

---

## Business Logic Decision Matrix

| Criterion | Business Rule | Power Automate | Plugin | Custom API |
|-----------|--------------|----------------|--------|------------|
| Complexity | Simple field logic | Multi-step | Complex | Reusable endpoint |
| Cross-entity | No | Yes | Yes | Yes |
| External calls | No | Yes | Yes (async) | Yes |
| Performance | Client-side (fast) | Medium | Varies | Varies |
| Maintenance | Citizen dev | Power user | Developer | Developer |
| Testability | Manual | Manual | Unit testable | Unit testable |
| Transaction | Client (unreliable) | Server | Server | Server |

Decision flow:
1. Business Rule handles it? → Use it
2. Multi-step, no code? → Power Automate
3. Server-side guarantee? → Plugin
4. Reusable API for external callers? → Custom API

---

## Virtual Entities

**Use when**: read-only external data that appears in views/grids without storing in Dataverse.

Constraints: read-only by default, limited query operators, performance depends on source, cannot be child in relationships.

---

## Elastic Tables

**Use when**: high-volume transactional data (millions of records), IoT telemetry, short retention.

Constraints: partition key required, limited relationships, JSON columns for semi-structured, no advanced find.

---

## Choice (OptionSet) Design

| Global | Local |
|--------|-------|
| Shared across tables (Status, Priority) | Specific to one table |
| Changes affect all usages | Isolated changes |

Rules:
- Start custom values at 100000000
- Leave gaps (100000000, 100000010, 100000020)
- Document value meanings

---

## Activity Entities

Use custom activities when: tracking specific interaction type, need custom fields, require specific views/forms.

Principles: inherit from ActivityPointer, use Regarding lookup, leverage activity parties for From/To.

---

## Anti-Patterns

| Avoid | Prefer |
|-------|--------|
| God Entity (200+ columns) | Proper table decomposition |
| Excessive denormalization | Normalized relationships |
| String for structured data | Correct column types (Date, Currency) |
| Storing structured data in Notes | Dedicated tables |
| Deep hierarchy (>5 levels) | Flatter structure |
| Ignoring platform limits | Design within API/storage quotas |
| No alternate keys | Add for queried/integrated columns |
