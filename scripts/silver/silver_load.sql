WITH depulicated_crm_cust_info AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS row_num
    FROM `dw_bronze.crm_cust_info`
)
SELECT cst_id,
	   cst_key,
       LTRIM(cst_firstname) as cst_firstname,
       LTRIM(cst_lastname) as cst_lastname,
       CASE 
       		WHEN UPPER(LTRIM(cst_marital_status)) = 'S' THEN 'Single'
            WHEN UPPER(LTRIM(cst_marital_status)) = 'M' THEN 'Married'
            ELSE 'n/a'
       END AS cst_marital_status,
       CASE 
       		WHEN UPPER(LTRIM(cst_gndr)) = 'F' THEN 'Female'
            WHEN UPPER(LTRIM(cst_gndr)) = 'M' THEN 'Male' -- <--- Recommended addition
        	ELSE 'n/a'
       END AS cst_gndr,
       cst_create_date
FROM depulicated_crm_cust_info
WHERE row_num = 1 AND cst_id != 0;
            
       
SELECT
	prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, -- Extract category key, the first 4 digit
    SUBSTRING(prd_key, 7) AS prd_key_cleaned, -- Extract product key, starting from the 7th to the end 
    prd_nm,
    IFNULL(prd_cost, 0) as prd_cost,
    CASE UPPER(LTRIM(prd_line))
		WHEN 'M' THEN 'Mountain'
		WHEN 'R' THEN 'Road'
		WHEN 'S' THEN 'Other Sales'
		WHEN 'T' THEN 'Touring'
		ELSE 'n/a'
	END AS prd_line,
    CAST(prd_start_dt AS DATE) AS prd_start_dt, 
    CAST(
    DATE_SUB(
        LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt), 
        INTERVAL 1 DAY
    ) AS DATE
) AS prd_end_dt_calculated -- Calculate end date as one day before the next start date
FROM dw_bronze.crm_prd_info;

SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    CASE WHEN sls_order_dt = 0
        OR LENGTH(sls_order_dt) != 8 THEN
        NULL
    ELSE
        CAST(CAST(sls_order_dt AS char) AS DATE)
    END AS sls_order_dt,
    CASE WHEN sls_ship_dt = 0
        OR LENGTH(sls_ship_dt) != 8 THEN
        NULL
    ELSE
        CAST(CAST(sls_ship_dt AS char) AS DATE)
    END AS sls_ship_dt,
    CASE WHEN sls_due_dt = 0
        OR length(sls_due_dt) != 8 THEN
        NULL
    ELSE
        CAST(CAST(sls_due_dt AS char) AS DATE)
    END AS sls_due_dt,
    CASE WHEN sls_sales IS NULL
        OR sls_sales <= 0
        OR sls_quantity * ABS(sls_price) THEN
        sls_quantity * ABS(sls_price)
    ELSE
        sls_sales
    END AS sls_sales, -- Recalculate sales if original value is missing or incorrect
    CASE WHEN sls_price IS NULL
        OR sls_price <= 0 THEN
        sls_sales / NULLIF (sls_quantity, 0)
    ELSE
        sls_price
    END AS sls_price
FROM
    dw_bronze.crm_sales_details;






