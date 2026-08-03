{{ config(materialized='view') }}
SELECT
    id,
    cat,
    subcat,
    maintenance
FROM
    {{ ref ('PX_CAT_G1V2') }}
