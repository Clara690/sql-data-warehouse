/*
=============================================================
Create Databases for Medallion Architecture (MySQL)
=============================================================
Script Purpose:
    This script drops and recreates the databases for the 
    'bronze', 'silver', and 'gold' layers.

WARNING:
    Running this script will drop 'DataWarehouse_bronze', 
    'DataWarehouse_silver', and 'DataWarehouse_gold' if they exist. 
    All data will be permanently deleted.
=============================================================
*/

-- Drop existing databases if they exist
-- DROP DATABASE IF EXISTS dw_bronze;
-- DROP DATABASE IF EXISTS dw_silver;
-- DROP DATABASE IF EXISTS dw_gold;

-- Create databases for each layer
CREATE DATABASE dw_bronze;
CREATE DATABASE dw_silver;
CREATE DATABASE dw_gold;