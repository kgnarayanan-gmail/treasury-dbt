{{
    config(
        materialized='view',
        schema='staging'
    )
}}

-- Staging model for ACDOCA transactions
-- Combines both sample and JNJ data with basic cleaning

with acdoca_sample as (
    select
        id::bigint as id,
        company_code::varchar as company_code,
        account_number::varchar as account_number,
        posting_date::date as posting_date,
        document_number::varchar as document_number,
        local_amount::numeric as local_amount,
        local_currency::varchar as local_currency,
        cashflow_category::varchar as cashflow_category,
        created_at::timestamp as created_at,
        'SAMPLE' as data_source
    from {{ source('treasury', 'acdoca') }}
),

acdoca_jnj as (
    select
        id::bigint as id,
        company_code::varchar as company_code,
        account_number::varchar as account_number,
        posting_date::date as posting_date,
        document_number::varchar as document_number,
        local_amount::numeric as local_amount,
        local_currency::varchar as local_currency,
        cashflow_category::varchar as cashflow_category,
        created_at::timestamp as created_at,
        'JNJ' as data_source
    from {{ source('treasury', 'acdoca_jnj') }}
),

combined as (
    select * from acdoca_sample
    union all
    select * from acdoca_jnj
)

select
    -- Primary key (make unique across sources)
    case
        when data_source = 'SAMPLE' then id::bigint
        when data_source = 'JNJ' then id::bigint + 1000000  -- Offset JNJ IDs
    end as transaction_id,

    -- Business keys
    company_code,
    account_number,
    document_number,

    -- Dates
    posting_date::date as posting_date,
    extract(year from posting_date) as fiscal_year,
    extract(quarter from posting_date) as fiscal_quarter,
    extract(month from posting_date) as fiscal_month,

    -- Amounts
    local_amount::numeric(18,2) as amount_local,
    local_currency as currency_code,

    -- Classification
    cashflow_category,

    -- Metadata
    data_source,
    created_at::timestamp as loaded_at,
    current_timestamp as dbt_updated_at

from combined

-- Data quality filters
where posting_date is not null
  and local_amount is not null
  and company_code is not null
  and account_number is not null
