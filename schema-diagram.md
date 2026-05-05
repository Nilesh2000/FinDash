# FinDash Database Schema Diagram

```mermaid
erDiagram
    mutual_funds {
        int id PK
        int scheme_code UK
        text scheme_name
        text fund_house
        text scheme_category
        text scheme_type
        text asset_class
        text fund_type
        text risk_level
        text benchmark
        text plan_type
        text option_type
        numeric expense_ratio
        date inception_date
        timestamp created_at
        timestamp updated_at
    }

    nav_history {
        int id PK
        int mf_id FK
        date date
        numeric nav
    }

    transactions {
        int id PK
        int mf_id FK
        text txn_type
        date txn_date
        numeric units
        numeric nav
        numeric txn_amount
        timestamp created_at
    }

    mutual_funds ||--o{ nav_history : "id -> mf_id (ON DELETE CASCADE)"
    mutual_funds ||--o{ transactions : "id -> mf_id (ON DELETE CASCADE)"
```

## Notes

- Primary keys: `mutual_funds.id`, `nav_history.id`, `transactions.id`
- Foreign keys: `nav_history.mf_id` and `transactions.mf_id` reference `mutual_funds.id`
- `ON DELETE CASCADE` is configured for both child tables
