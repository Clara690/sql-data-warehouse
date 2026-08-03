{{ config(materialized='view') }}
SELECT
    replace(cid, '-', '') AS cid,
    CASE WHEN trim(cntry) = 'DE' THEN
        'Germany'
    WHEN trim(cntry) IN ('US', 'USA') THEN
        'United States'
    WHEN trim(cntry) = ''
        OR cntry IS NULL THEN
        'n/a'
    ELSE
        trim(cntry)
    END AS cntry
FROM
    {{ ref ('LOC_A101') }}
