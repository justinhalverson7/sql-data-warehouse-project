/*
============================================================
Create Database and Schemas
============================================================

Script Purpose:
    This script creates a new database named 'DataWarehouse' after checking if it already exists.
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas
    within the database: 'bronze', 'silver', and 'gold'.

WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it exists.
    All data in the database will be permanently deleted. Proceed with caution
    and ensure you have proper backups before running this script.
*/
use master; 
go


--Drop and recreate the 'DataWarehouse' database
If exists (Select 1 from sys.databases where name = 'DataWarehouse')
begin
    Alter DATABASE DataWarehouse set single_user With Rollback Immediate;
    Drop DATABASE DataWarehouse;
End;
GO

-- Create and Use DataWarehouse
create database DataWarehouse;

use  DataWarehouse;

-- Create Schemas
Create schema bronze;

Create schema silver;

Create schema gold;
