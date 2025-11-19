/* DDL Commands: Creating silver Tables */

if object_id('silver.crm_cust_info','u') is not null
drop table silver.crm_cust_info;
create table silver.crm_cust_info(
cst_id int,
cst_key nvarchar(50),
cst_firstname nvarchar(50),
cst_lastname nvarchar(50),
cst_marital_status nvarchar(50),
cst_gndr nvarchar(50),
cst_create_date date,
dwh_create_date datetime2 default getdate()
);

if object_id('silver.crm_prd_info','u') is not null
drop table silver.crm_prd_info;
create table silver.crm_prd_info(
prd_id int,
prd_key nvarchar(50),
prd_nm nvarchar(50),
prd_cost nvarchar(50),
prd_line nvarchar(50),
prd_start_dt date,
prd_end_dt date,
dwh_create_date datetime2 default getdate()

);

if object_id('silver.crm_sales_datails','u') is not null
drop table silver.crm_sales_datails;
create table silver.crm_sales_datails(
sls_ord_num nvarchar(50),
sls_prd_key nvarchar(50),
sls_cust_id int,
sls_order_dt date,
sls_ship_dt date,
sls_due_dt date,
sls_sales int,
sls_quantity int,
sls_price int,
dwh_create_date datetime2 default getdate()
);

if object_id('silver.erp_cust_az12','u') is not null
drop table silver.erp_cust_az12;
create table silver.erp_cust_az12(
cid int,
bdate date,
gen nvarchar(50),
dwh_create_date datetime2 default getdate()
);

if object_id('silver.erp_loc_a101','u') is not null
drop table silver.erp_loc_a101;
create table silver.erp_loc_a101(
cid int,
cntry nvarchar(50),
dwh_create_date datetime2 default getdate()
);

if object_id('silver.erp_px_cat_g1v2','u') is not null
drop table silver.erp_px_cat_g1v2;
create table silver.erp_px_cat_g1v2(
id int,
cat nvarchar(50),
subcat nvarchar(50),
maintenance nvarchar(50),
dwh_create_date datetime2 default getdate()
);

Alter table silver.erp_px_cat_g1v2 alter column id nvarchar(50);
Alter table silver.erp_loc_a101 alter column cid nvarchar(50);
Alter table silver.erp_cust_az12 alter column cid nvarchar(50);
Alter table silver.crm_sales_datails alter column sls_cust_id int;
Alter table silver.crm_sales_datails alter column sls_order_dt int;
Alter table silver.crm_sales_datails alter column sls_ship_dt int;
Alter table silver.crm_prd_info alter column prd_cost int;
