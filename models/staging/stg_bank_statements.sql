{{
    config(
        materialized='view',
        schema='staging'
    )
}}

-- Staging model for bank statements
-- Basic cleaning and standardization

select
    -- Primary key
    id::bigint as statement_id,

    -- Business keys
    company_code,
    bank_account,
    bank_reference,

    -- Dates
    statement_date::date as statement_date,
    value_date::date as value_date,
    extract(year from value_date) as fiscal_year,
    extract(quarter from value_date) as fiscal_quarter,
    extract(month from value_date) as fiscal_month,

    -- Amounts
    amount::numeric(18,2) as amount,
    currency,

    -- Description
    description,

    -- Metadata
    created_at::timestamp as loaded_at,
    current_timestamp as dbt_updated_at

from {{ source('treasury', 'bank_statements') }}

-- Data quality filters
where statement_date is not null
  and amount is not null
  and company_code is not null
  and bank_account is not null
