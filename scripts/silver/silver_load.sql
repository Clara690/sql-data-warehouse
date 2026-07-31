WITH depulicated_crm_cust_info AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS row_num
    FROM `crm_cust_info`
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
            
       
