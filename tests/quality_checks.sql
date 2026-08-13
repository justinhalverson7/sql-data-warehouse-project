-- Check for Nulls or Duplicated in Primary Key
-- Expectation: No Results

select 
cst_id, 
count(*)
from silver.crm_cust_info
group by cst_id
having count(*) > 1 or cst_id is null

-- Check for Unwanted Spaces
-- Expectation: No Results
select cst_firstname
from silver.crm_cust_info
where cst_firstname != trim(cst_firstname)

select cst_lastname
from silver.crm_cust_info
where cst_lastname != trim(cst_lastname)

select cst_gendr
from silver.crm_cust_info
where cst_gendr != trim(cst_gendr)

select *
from silver.crm_cust_info

SELECT
    prd_id,
    COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1
    OR prd_id IS NULL;
