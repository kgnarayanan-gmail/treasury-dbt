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
          CAST(id AS INT64) as id,
          CAST(company_code AS STRING) as company_code,
          CAST(account_number AS STRING) as account_number,
          CAST(posting_date AS DATE) as posting_date,
          CAST(document_number AS STRING) as document_number,
          CAST(local_amount AS NUMERIC) as local_amount,
          CAST(local_currency AS STRING) as local_currency,
          CAST(cashflow_category AS STRING) as cashflow_category,
          CAST(created_at AS TIMESTAMP) as created_at,
          'SAMPLE' as data_source
      from {{ source('treasury', 'acdoca') }}
  ),

  acdoca_jnj as (
      select
          CAST(id AS INT64) as id,
          CAST(company_code AS STRING) as company_code,
          CAST(account_number AS STRING) as account_number,
          CAST(posting_date AS DATE) as posting_date,
          CAST(document_number AS STRING) as document_number,
          CAST(local_amount AS NUMERIC) as local_amount,
          CAST(local_currency AS STRING) as local_currency,
          CAST(cashflow_category AS STRING) as cashflow_category,
          CAST(created_at AS TIMESTAMP) as created_at,
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
          when data_source = 'SAMPLE' then CAST(id AS INT64)
          when data_source = 'JNJ' then CAST(id AS INT64) + 1000000  -- Offset JNJ IDs
      end as transaction_id,

      -- Business keys
      company_code,
      account_number,
      document_number,

      -- Dates
      CAST(posting_date AS DATE) as posting_date,
      extract(year from posting_date) as fiscal_year,
      extract(quarter from posting_date) as fiscal_quarter,
      extract(month from posting_date) as fiscal_month,

      -- Amounts
      CAST(local_amount AS NUMERIC) as amount_local,
      local_currency as currency_code,

      -- Classification
      cashflow_category,

      -- Metadata
      data_source,
      CAST(created_at AS TIMESTAMP) as loaded_at,
      current_timestamp() as dbt_updated_at

  from combined

  -- Data quality filters
  where posting_date is not null
    and local_amount is not null
    and company_code is not null
    and account_number is not null
