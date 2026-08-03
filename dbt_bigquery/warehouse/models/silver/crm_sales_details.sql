{{ config(materialized='view') }}
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    safe.parse_date ('%Y%m%d', cast(sls_order_dt AS string)) AS sls_order_dt,
    safe.parse_date ('%Y%m%d', cast(sls_ship_dt AS string)) AS sls_ship_dt,
    safe.parse_date ('%Y%m%d', cast(sls_due_dt AS string)) AS sls_due_dt,
    CASE WHEN sls_sales IS NULL
        OR sls_sales <= 0
        OR sls_sales != (sls_quantity * abs(sls_price)) THEN
        sls_quantity * abs(sls_price)
    ELSE
        sls_sales
    END AS sls_sales,
    sls_quantity,
    CASE WHEN sls_price IS NULL
        OR sls_price <= 0 THEN
        sls_sales / nullif (sls_quantity, 0)
    ELSE
        sls_price
    END AS sls_price
FROM
    {{ ref ('sales_details') }}
