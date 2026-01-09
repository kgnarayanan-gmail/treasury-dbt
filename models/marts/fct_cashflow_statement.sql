{{
    config(
        materialized='table',
        schema='analytics'
    )
}}

-- Cashflow Statement Fact Table
-- Aggregates transactions by period and category

with transactions as (
    select *
    from {{ ref('stg_acdoca') }}
),

aggregated as (
    select
        -- Time dimension
        fiscal_year,
        fiscal_quarter,
        fiscal_month,
        to_char(posting_date, 'YYYY-MM') as period_month,

        -- Business dimensions
        company_code,
        cashflow_category,
        data_source,

        -- Metrics
        count(*) as transaction_count,
        sum(amount_local) as total_amount,
        avg(amount_local) as avg_amount,
        min(amount_local) as min_amount,
        max(amount_local) as max_amount,

        -- Date tracking
        min(posting_date) as period_start_date,
        max(posting_date) as period_end_date,
        current_timestamp as dbt_updated_at

    from transactions
    group by
        fiscal_year,
        fiscal_quarter,
        fiscal_month,
        period_month,
        company_code,
        cashflow_category,
        data_source
)

select
    -- Generate surrogate key
    {{ dbt_utils.generate_surrogate_key(['period_month', 'company_code', 'cashflow_category', 'data_source']) }} as cashflow_statement_key,

    *

from aggregated
order by
    period_month desc,
    company_code,
    cashflow_category
