--Silver Layer Stored Procedure
--Loading Silver Layer Tables

create or alter procedure silver.load_silver AS
begin
    declare @start_time datetime, @end_time datetime, @batch_start_time datetime, @batch_end_time datetime 
    Begin try
        set @batch_start_time = getdate();
        PRINT '=========================';
        PRINT 'Loading Silver Layer';
        PRINT '=========================';

        PRINT '-------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '-------------------------';

-- Loading silver.crm_cust_info
    set @start_time = getdate();
    print '>> Truncating Table: silver.crm_cust_info';
    truncate table silver.crm_cust_info;
    print '>> Inserting Data Into: silver.crm_cust_info';
    insert into silver.crm_cust_info (
	    cst_id,
	    cst_key,
	    cst_firstname,
	    cst_lastname,
	    cst_marital_status,
	    cst_gendr,
	    cst_create_date)

    select 
    cst_id,
    cst_key,
    trim(cst_firstname) as cst_firstname,
    trim(cst_lastname) as cst_lastname,
    case when Upper(Trim(cst_marital_status)) = 'S' then 'Single'
	     when Upper(Trim(cst_marital_status)) = 'M' then 'Married'
	     else 'unknown'
    end cst_marital_status,
    case when Upper(Trim(cst_gendr)) = 'F' then 'Female'
	     when Upper(Trim(cst_gendr)) = 'M' then 'Male'
	     else 'unknown'
    end cst_gndr,
    cst_create_date
    From(
    select *,
    row_number() over (partition by cst_id Order by cst_create_date DESC) as flag_last
    from bronze.crm_cust_info
    )t where flag_last = 1
    set @end_time =getdate();

-- Loading silver.crm_prd_info
    set @start_time = getdate();
    print '>> Truncating Table: silver.crm_prd_info';
    truncate table silver.crm_prd_info;
    print '>> Inserting Data Into: silver.crm_prd_info';
    Insert into silver.crm_prd_info (
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_date
    )
    SELECT 
        prd_id,
        replace(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
        substring(prd_key, 7, len(prd_key)) as prd_key,
        prd_nm,
        isnull(prd_cost, 0) as prd_cost,
        case upper(trim(prd_line))
             when 'M' then 'Mountain'
             when 'R' then 'Road'
             when 'S' then 'other Sales'
             when 'T' then 'Touring'
             Else 'unknown'
    end as prd_line,
        cast (prd_start_dt as date) as prd_start_dt,
        cast(lead(prd_start_dt) over (partition by prd_key order by prd_start_dt) -1 as date) as prd_end_dt
    FROM bronze.crm_prd_info
    set @end_time =getdate();

-- Loading silver.crm_sales_details
    set @start_time = getdate();
    print '>> Truncating Table: silver.crm_sales_details';
    truncate table silver.crm_sales_details;
    print '>> Inserting Data Into: silver.crm_sales_details';
    INSERT INTO silver.crm_sales_details(
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_ord_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price
    )
    SELECT 
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,

        CASE 
            WHEN sls_ord_dt = 0 OR LEN(sls_ord_dt) != 8 THEN NULL
            ELSE CAST(CAST(sls_ord_dt AS VARCHAR) AS DATE)
        END AS sls_ord_dt,

        CASE 
            WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
            ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
        END AS sls_ship_dt,

        CASE 
            WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
            ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
        END AS sls_due_dt,

        CASE 
            WHEN sls_sales IS NULL 
              OR sls_sales <= 0 
              OR sls_sales != sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales
        END AS sls_sales,

        sls_quantity,

        CASE 
            WHEN sls_price IS NULL OR sls_price <= 0
            THEN sls_sales / NULLIF(sls_quantity, 0)
            ELSE sls_price
        END AS sls_price

    FROM DataWarehouse.bronze.crm_sales_details;
    set @end_time =getdate();


        PRINT '-------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '-------------------------';
   
-- Loading silver.erp_cust_az12
   set @start_time = getdate();
   print '>> Truncating Table: silver.erp_cust_az12';
    truncate table silver.erp_cust_az12;
    print '>> Inserting Data Into: silver.erp_cust_az12';
    insert into silver.erp_cust_az12(
    cid, 
    bdate, 
    gen
    )

    select
    case when cid like 'NAS%' then substring(cid, 4, len(cid))
    else cid
    end as cid,
    case when bdate > getdate() then null
    else bdate
    end as bdate,
    case when upper(trim(gen)) in ('M', 'Male') then 'Male'
	     when upper(trim(gen)) in ('F', 'Female') then 'Female'
	     else 'unknown'
	     end as gen
    from bronze.erp_cust_az12
    set @end_time =getdate();

-- Loading silver.erp_loc_a101
    set @start_time = getdate();
    print '>> Truncating Table: silver.erp_loc_a101';
    truncate table silver.erp_loc_a101;
    print '>> Inserting Data Into: silver.erp_loc_a101';
    insert into silver.erp_loc_a101(
    cid, 
    cntry
    )

    select
    replace(cid, '-', '') cid,
    case when trim(cntry) = 'DE' then 'Germany'
	     when trim(cntry) in ('USA', 'US') then 'United States'
	     when trim(cntry) = '' or cntry is null then 'unknown'
	     else trim(cntry)
    end as cnrty
    from bronze.erp_loc_a101
    set @end_time =getdate();


-- Loading silver.erp_px_cat_g1v2
    set @start_time = getdate();
    print '>> Truncating Table: silver.erp_px_cat_g1v2';
    truncate table silver.erp_px_cat_g1v2;
    print '>> Inserting Data Into: silver.erp_px_cat_g1v2';
    insert into silver.erp_px_cat_g1v2(
    id,
    cat,
    subcat,
    maintinence
    )

    select 
    id,
    cat,
    subcat,
    maintinence
    from bronze.erp_px_cat_g1v2
    set @end_time =getdate();

     PRINT '>> Data Loaded Successfully';

    END TRY
    BEGIN CATCH

        PRINT '==========================================';
        PRINT 'ERROR OCCURRED DURING LOADING SILVER LAYER';
        PRINT '==========================================';

        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR(10));

    END CATCH
END
