{{ config(materialized='view') }}
SELECT
    CASE WHEN cid LIKE 'NAS%' THEN
        substring(cid, 4)
    ELSE
        cid
    END AS cid,
    CASE WHEN bdate > current_date() THEN
        NULL
    ELSE
        bdate
    END AS bdate,
    CASE WHEN upper(trim(gen)) IN ('F', 'FEMALE') THEN
        'Female'
    WHEN upper(trim(gen)) IN ('M', 'MALE') THEN
        'Male'
    ELSE
        'n/a'
    END AS gen
FROM
    {{ ref ('CUST_AZ12') }}
