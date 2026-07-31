/*
===============================================================================
Script Purpose:
    This script creates tables in the 'dw_bronze' database if they do not exist
	  Run this script to re-define the DDL structure of 'bronze' tables
===============================================================================
*/

CREATE TABLE IF NOT EXISTS dw_bronze.crm_cust_info(
	cst_id INT,
    cst_key CHAR(50),
    cst_firstname CHAR(50),
    cst_lastname CHAR(50),
    cst_marital_status CHAR(50),
    cst_gndr CHAR(50),
    cst_create_date DATE
);


CREATE TABLE IF NOT EXISTS dw_bronze.crm_prd_info (
    prd_id INT,
    prd_key CHAR(50),
    prd_nm CHAR(50),
    prd_cost INT,
    prd_line CHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt DATETIME
);


CREATE TABLE IF NOT EXISTS dw_bronze.crm_sales_details (
    prd_id INT,
    prd_key CHAR(50),
    prd_nm CHAR(50),
    prd_cost INT,
    prd_line CHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt DATETIME
);

CREATE TABLE IF NOT EXISTS dw_bronze.erp_loc_a101(
	cid CHAR(50),
    cntry CHAR(50)
);

CREATE TABLE IF NOT EXISTS dw_bronze.erp_cust_az12(
	cid CHAR(50),
    bdate DATE,
    gen CHAR(50)
);

CREATE TABLE IF NOT EXISTS dw_bronze.erp_px_cat_g1v2(
	id CHAR(50),
    cat CHAR(50),
    subcat CHAR(50),
    maintenance CHAR(50)
);