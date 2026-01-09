{{
    config(
        materialized='table',
        schema='analytics'
    )
}}

-- Daily Cash Position Fact Table
-- Running balance by company and date

with transactions as (
    select
        posting_date,
        company_code,
        amount_local,
        cashflow_category
    from {{ ref('stg_acdoca') }}
),

daily_aggregated as (
    select
        posting_date,
        company_code,
        sum(amount_local) as daily_net_cashflow,
        sum(case when amount_local > 0 then amount_local else 0 end) as daily_inflows,
        sum(case when amount_local < 0 then amount_local else 0 end) as daily_outflows,
        count(*) as transaction_count
    from transactions
    group by posting_date, company_code
),

running_balance as (
    select
        posting_date,
        company_code,
        daily_net_cashflow,
        daily_inflows,
        daily_outflows,
        transaction_count,
        sum(daily_net_cashflow) over (
            partition by company_code
            order by posting_date
            rows between unbounded preceding and current row
        ) as running_balance,
        current_timestamp as dbt_updated_at
    from daily_aggregated
)

select
    -- Generate surrogate key
    {{ dbt_utils.generate_surrogate_key(['posting_date', 'company_code']) }} as cash_position_key,

    *

from running_balance
order by company_code, posting_date desc
