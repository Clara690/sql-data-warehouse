DELIMITER //

DROP PROCEDURE IF EXISTS dw_silver.load_silver //

CREATE PROCEDURE dw_silver.load_silver()
BEGIN
    -- Error handling variables
    DECLARE err_code INT DEFAULT 0;
    DECLARE err_msg TEXT;

    -- Define Error Handler for any SQL Exception
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Capture Error Information
        GET DIAGNOSTICS CONDITION 1
            err_code = MYSQL_ERRNO,
            err_msg = MESSAGE_TEXT;
            
        -- Rollback transaction to preserve data integrity
        ROLLBACK;
        
        -- Signal error to the client session
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = err_msg;
    END;

    -- Start Transaction
    START TRANSACTION;

    -- =========================================================================
    -- CRM SECTION
    -- =========================================================================

    -- Table 1: dw_silver.crm_cust_info
    TRUNCATE TABLE dw_silver.crm_cust_info;

    INSERT INTO dw_silver.crm_cust_info (
        cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date
    )
    WITH deduplicated_crm_cust_info AS (
        SELECT 
            *,
            ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS row_num
        FROM dw_bronze.crm_cust_info
    )
    SELECT 
        cst_id,
        cst_key,
        TRIM(cst_firstname) AS cst_firstname,
        TRIM(cst_lastname) AS cst_lastname,
        CASE 
            WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
            WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
            ELSE 'n/a'
        END AS cst_marital_status,
        CASE 
            WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
            WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
            ELSE 'n/a'
        END AS cst_gndr,
        cst_create_date
    FROM deduplicated_crm_cust_info
    WHERE row_num = 1 AND cst_id IS NOT NULL AND cst_id != 0;

    -- Table 2: dw_silver.crm_prd_info
    TRUNCATE TABLE dw_silver.crm_prd_info;

    INSERT INTO dw_silver.crm_prd_info (
        prd_id, cat_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt
    )
    SELECT
        prd_id,
        REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
        SUBSTRING(prd_key, 7) AS prd_key_cleaned,
        prd_nm,
        IFNULL(prd_cost, 0) AS prd_cost,
        CASE UPPER(TRIM(prd_line))
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
        ) AS prd_end_dt_calculated
    FROM dw_bronze.crm_prd_info;

    -- Table 3: dw_silver.crm_sales_details
    TRUNCATE TABLE dw_silver.crm_sales_details;

    INSERT INTO dw_silver.crm_sales_details (
        sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price
    )
    SELECT
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        CASE 
            WHEN sls_order_dt = 0 OR LENGTH(CAST(sls_order_dt AS CHAR)) != 8 THEN NULL
            ELSE STR_TO_DATE(CAST(sls_order_dt AS CHAR), '%Y%m%d')
        END AS sls_order_dt,
        CASE 
            WHEN sls_ship_dt = 0 OR LENGTH(CAST(sls_ship_dt AS CHAR)) != 8 THEN NULL
            ELSE STR_TO_DATE(CAST(sls_ship_dt AS CHAR), '%Y%m%d')
        END AS sls_ship_dt,
        CASE 
            WHEN sls_due_dt = 0 OR LENGTH(CAST(sls_due_dt AS CHAR)) != 8 THEN NULL
            ELSE STR_TO_DATE(CAST(sls_due_dt AS CHAR), '%Y%m%d')
        END AS sls_due_dt,
        CASE 
            WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != (sls_quantity * ABS(sls_price)) 
                THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales
        END AS sls_sales,
        sls_quantity,
        CASE 
            WHEN sls_price IS NULL OR sls_price <= 0 
                THEN sls_sales / NULLIF(sls_quantity, 0)
            ELSE sls_price
        END AS sls_price
    FROM dw_bronze.crm_sales_details;

    -- =========================================================================
    -- ERP SECTION
    -- =========================================================================

    -- Table 4: dw_silver.erp_cust_az12
    TRUNCATE TABLE dw_silver.erp_cust_az12;

    INSERT INTO dw_silver.erp_cust_az12 (cid, bdate, gen)
    SELECT
        CASE 
            WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4)
            ELSE cid
        END AS cid,
        CASE 
            WHEN bdate > NOW() THEN NULL
            ELSE bdate
        END AS bdate,
        CASE 
            WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
            WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
            ELSE 'n/a'
        END AS gen
    FROM dw_bronze.erp_cust_az12;

    -- Table 5: dw_silver.erp_loc_a101
    TRUNCATE TABLE dw_silver.erp_loc_a101;

    INSERT INTO dw_silver.erp_loc_a101 (cid, cntry)
    SELECT
        REPLACE(cid, '-', '') AS cid,
        CASE 
            WHEN TRIM(cntry) = 'DE' THEN 'GERMANY'
            WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
            WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
            ELSE TRIM(cntry)
        END AS cntry
    FROM dw_bronze.erp_loc_a101;

    -- Table 6: dw_silver.erp_px_cat_g1v2
    TRUNCATE TABLE dw_silver.erp_px_cat_g1v2;

    INSERT INTO dw_silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
    SELECT
        id,
        cat,
        subcat,
        maintenance
    FROM dw_bronze.erp_px_cat_g1v2;

    -- Commit if all operations succeed
    COMMIT;

END //

DELIMITER ;