from scripts.config import MYSQL_ROOT_PASSWORD 
import time
import mysql.connector
from mysql.connector import Error

# connection settings
DB_CONFIG = {
    'host': '127.0.0.1',
    'port': 3306,
    'user': 'root',
    'password': MYSQL_ROOT_PASSWORD,
    'database':'dw_bronze',
    'allow_local_infile': True,
}

# all the csv files to load
TABLES = {
    'crm_cust_info': 'datasets/source_crm/cust_info.csv',
    'crm_prd_info': 'datasets/source_crm/prd_info.csv',
    'crm_sales_details': 'datasets/source_crm/sales_details.csv',
    'erp_cust_az12': 'datasets/source_erp/CUST_AZ12.csv',
    'erp_loc_a101': 'datasets/source_erp/LOC_A101.csv',
    'erp_px_cat_g1v2': 'datasets/source_erp/PX_CAT_G1V2.csv',
}

def load_bronze():
    conn = None
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor()

        batch_start = time.time()
        print('=' * 50)
        print('Loading Bronze Layer')
        print('=' * 50)

        for table, csv_file in TABLES.items():
            start = time.time()

            print(f'\n >> Truncating table: {table}')
            cursor.execute(f'TRUNCATE TABLE {table}')
            conn.commit()

            print(f'>> Loading data into: {table} from {{csv_file}}')
            load_sql = f"""
                LOAD DATA LOCAL INFILE %s
                INTO TABLE {table}
                FIELDS TERMINATED BY ','
                OPTIONALLY ENCLOSED BY '"'
                LINES TERMINATED BY '\\r\\n'
                IGNORE 1 LINES
            """
            cursor.execute(load_sql, (csv_file,))
            conn.commit()

            print(f'>> Rows loaded: {cursor.rowcount}')
            print(f'>> Duration: {time.time() - start:.2f}s')

        print('\n' + '*' * 50)
        print(f'Bronze layer load complete in {time.time() - batch_start:.2f}s')
        print('=' * 50)

    except Error as e:
        print(f'An error occured during load_bronze: {e}')
    finally:
        if conn is not None and conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == '__main__':
    load_bronze()