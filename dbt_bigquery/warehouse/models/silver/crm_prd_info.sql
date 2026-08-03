{{ config(materialized='view') }}
SELECT
    prd_id,
    replace(substring(prd_key, 1, 5), '-', '_') AS cat_id,
    substring(prd_key, 7) AS prd_key,
    prd_nm,
    ifnull (prd_cost, 0) AS prd_cost,
    CASE upper(trim(prd_line))
    WHEN 'M' THEN
        'Mountain'
    WHEN 'R' THEN
        'Road'
    WHEN 'S' THEN
        'Other Sales'
    WHEN 'T' THEN
        'Touring'
    ELSE
        'n/a'
    END AS prd_line,
    cast(prd_start_dt AS date) AS prd_start_dt,
    cast(date_sub (lead(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt), interval 1 day) AS date) AS prd_end_dt
FROM
    {{ ref ('prd_info') }}
