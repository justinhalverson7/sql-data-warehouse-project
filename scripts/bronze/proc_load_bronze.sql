/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================

Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files.
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from CSV Files to bronze tables.

Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/


create or alter procedure bronze.load_bronze as
    begin
    begin try
        Print '=========================';
        Print 'Loading Bronze Layer';
        Print '=========================';

        Print '-------------------------';
        Print 'Loading CRM Tables';
        Print' -------------------------';

        Print '>> Truncating Table: bronze.crm_cust_info';
        truncate table bronze.crm_cust_info;

        Print '>> Inserting Data into: bronze.crm_cust_info';
        BULK INSERT bronze.crm_cust_info
        FROM 'C:\Users\justi\Downloads\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        Print '>> Truncating Table: bronze.crm_prd_info';
        truncate table bronze.crm_prd_info;

        Print '>> Inserting Data into: bronze.crm_prd_info';
        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Users\justi\Downloads\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        Print '>> Truncating Table: bronze.crm_sales_details';
        truncate table bronze.crm_sales_details;

        Print '>> Inserting Data into: bronze.crm_sales_details';
        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Users\justi\Downloads\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        Print '-------------------------';
        Print 'Loading ERP Tables';
        Print' -------------------------';

        Print '>> Truncating Table: bronze.erp_cust_az12';
        truncate table bronze.erp_cust_az12;

        Print '>> Inserting Data into: bronze.erp_cust_az12';
        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\Users\justi\Downloads\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

       Print '>> Truncating Table: bronze.erp_loc_a101';
       truncate table bronze.erp_loc_a101;

        Print '>> Inserting Data into: bronze.erp_loc_a101';
        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\Users\justi\Downloads\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

       Print '>> Truncating Table: bronze.erp_px_cat_g1v2';
       truncate table bronze.erp_px_cat_g1v2;

        Print '>> Inserting Data into: bronze.erp_px_cat_g1v2';
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\Users\justi\Downloads\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        end try
        begin catch
            print '=============================';
            print 'error occured when loading bronze layer';
            print 'error message' + error_message();
            print 'error message' + cast (error_number() as nvarchar);
            print 'error message' + cast (error_state() as nvarchar);
            print '=============================';
        end catch
end
