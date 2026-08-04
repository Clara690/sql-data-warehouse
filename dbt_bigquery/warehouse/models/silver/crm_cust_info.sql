{{ config(materialized='view') }}

WITH deduplicated_crm_cust_info AS (
    SELECT
        *,
        row_number() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS row_num
    FROM
        {{ ref ('cust_info') }}
)
SELECT
    cst_id,
    cst_key,
    trim(cst_firstname) AS cst_firstname,
    trim(cst_lastname) AS cst_lastname,
    CASE WHEN upper(trim(cst_marital_status)) = 'S' THEN
        'Single'
    WHEN upper(trim(cst_marital_status)) = 'M' THEN
        'Married'
    ELSE
        'n/a'
    END AS cst_marital_status,
    CASE WHEN upper(trim(cst_gndr)) = 'F' THEN
        'Female'
    WHEN upper(trim(cst_gndr)) = 'M' THEN
        'Male'
    ELSE
        'n/a'
    END AS cst_gndr,
    cst_create_date
FROM
    deduplicated_crm_cust_info
WHERE
    row_num = 1
    AND cst_id IS NOT NULL
    AND cst_id != 0