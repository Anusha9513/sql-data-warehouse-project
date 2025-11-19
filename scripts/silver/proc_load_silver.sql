/* Store Procedure for silver layer */

create or alter procedure silver.load_silver as
begin
Declare @start_time datetime, @end_time datetime, @batch_start_time datetime, @batch_end_time datetime
begin try
set @batch_start_time=getdate();

print'===================================='
print 'Loading Silver layer'
print'===================================='

print'------------------------------------'
print 'Loading CRM Tables'
print'------------------------------------'

set @start_time=getdate();
Print'>> Truncating Table : silver.crm_cust_info';
truncate table silver.crm_cust_info ;
Print'>> Inserting data into : silver.crm_cust_info';

INSERT INTO silver.crm_cust_info (
			cst_id, 
			cst_key, 
			cst_firstname, 
			cst_lastname, 
			cst_marital_status, 
			cst_gndr,
			cst_create_date
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
			END AS cst_marital_status, -- Normalize marital status values to readable format
			CASE 
				WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				ELSE 'n/a'
			END AS cst_gndr, -- Normalize gender values to readable format
			cst_create_date
		FROM (
			SELECT
				*,
				ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
			FROM bronze.crm_cust_info
			WHERE cst_id IS NOT NULL
		) t
		WHERE flag_last = 1; -- Select the most recent record per customer
	set @end_time=getdate();
	print'>> Load Duration: '+CASt( Datediff(second, @start_time, @end_time) As nvarchar) + 'seconds';
print'>>--------------------';

----Loading silver.crm_prd_info
set @start_time=getdate();
	Print'>> Truncating Table : silver.crm_prd_info';
truncate table silver.crm_prd_info ;
Print'>> Inserting data into : silver.crm_prd_info';

insert into silver.crm_prd_info(
prd_id,
cat_id,
prd_key,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt)
SELECT [prd_id],
	  replace(substring(prd_key, 1, 5), '-', '_') as cat_id,
	  substring(prd_key, 7, len(prd_key)) as prd_key,
      [prd_nm],
	  isnull(prd_cost, 0) as 
      [prd_cost],
	  case  upper(trim(prd_line))
	  when 'M' then 'Mountain'
	  when  'R' then 'Road'
	  when 'S' then 'Other sales'
	  when 'T' then 'Touring'
	  Else 'n/a'
	 end As prd_line,
      [prd_start_dt],
	  lead(prd_start_dt) over (partition by prd_key order by prd_start_dt) as prd_end_dt
  FROM [DataWarehouse].[Bronze].[crm_prd_info]
  set @end_time=getdate()
  print'>> Load Duration: '+CASt( Datediff(second, @start_time, @end_time) As nvarchar) + 'seconds';
print'>>---------------';

---Loading silver.crm_sales_details
set @start_time=getdate();
  	Print'>> Truncating Table : silver.crm_sales_details';
truncate table silver.crm_sales_details ;
Print'>> Inserting data into : silver.crm_sales_details';

insert into silver.crm_sales_details(
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price
)
select 
sls_ord_num,
sls_prd_key,
sls_cust_id,
case when sls_order_dt =0 or len(sls_order_dt) !=8  then null
else cast(cast(sls_order_dt as varchar) as date)
end as sls_order_dt,
case when sls_ship_dt =0 or len(sls_ship_dt) !=8  then null
else cast(cast(sls_ship_dt as varchar) as date)
end as sls_ship_dt,
sls_due_dt,
 case when sls_sales is null or sls_sales<=0 or sls_sales!=sls_quantity * ABS(sls_price)
 Then sls_quantity * ABS(sls_price)
 Else  sls_sales
 end as sls_sales,
sls_quantity,
 case when sls_price is null or sls_price<=0
 then sls_sales/nullif (sls_quantity,0) 
 else sls_price
 end as sls_price from bronze.crm_sales_details
  set @end_time=getdate()
  print'>> Load Duration: '+CASt( Datediff(second, @start_time, @end_time) As nvarchar) + 'seconds';
print'>>---------------';

print'------------------------------------'
print 'Loading ERP Tables'
print'------------------------------------'

---Loading silver.erp_cust_az12
set @start_time=getdate(); 
  	Print'>> Truncating Table : silver.erp_cust_az12';
truncate table silver.erp_cust_az12 ;
Print'>> Inserting data into : silver.erp_cust_az12';

insert into silver.erp_cust_az12
(
cid,bdate,gen)
select 
case when cid like 'NAS%' then substring(cid, 4, len(cid))---removes 'NAS' prefix if present
else cid
end cid,
case when bdate> getdate() then null
else bdate
end as bdate, ---set future birthdates to null
 case when upper(trim(gen)) in ('F','FEMALE') then 'Female'
when upper(trim(gen)) in ('M','MALE') then 'Male'
  else 'n/a'
  end as gen---Normalize gender values and handle unknown cases
from Bronze.erp_cust_az12
set @end_time=getdate();
print'>> Load Duration: '+CASt( Datediff(second, @start_time, @end_time) As nvarchar) + 'seconds';
print'>>---------------'

---Loading silver.erp_loc_a101
set @start_time=getdate();
Print'>> Truncating Table : silver.erp_loc_a101';
truncate table silver.erp_loc_a101 ;
Print'>> Inserting data into :silver.erp_loc_a101';

insert into silver.erp_loc_a101
(cid,cntry)
select replace(cid,'-','')cid,
case when trim(cntry)= 'DE' then 'Germany'
when trim(cntry) in ('US','USA') then 'United States'
when trim(cntry)='' or cntry is null then 'n/a'
else trim(cntry)
end as cntry 
from Bronze.erp_loc_a101
set @end_time=getdate();
print'>> Load Duration: '+CASt( Datediff(second, @start_time, @end_time) As nvarchar) + 'seconds';
print'>>---------------'

---Loading silver.erp_px_cat_g1v2
set @start_time=getdate();
 	Print'>> Truncating Table : silver.erp_px_cat_g1v2';
truncate table silver.erp_px_cat_g1v2 ;
Print'>> Inserting data into :silver.erp_px_cat_g1v2';

insert into silver.erp_px_cat_g1v2
(id,cat,subcat,maintenance)
select id,
cat,
subcat,
maintenance from bronze.erp_px_cat_g1v2
set @end_time=getdate();
print'>> Load Duration: '+CASt( Datediff(second, @start_time, @end_time) As nvarchar) + 'seconds';
print'>>---------------';

set @batch_end_time=getdate();
print'==============================='
 print'Loading Silver layer is completed';
 print'  -Total Load duration:' +cast(datediff(second, @batch_start_time, @batch_end_time) As nvarchar) + 'seconds';
 print'==============================='
end try
begin catch 
print'==================================='
print'Error occured during loading Silver layer'
print'Error message' + Error_message();
print'Error message' + CAST(Error_number() AS NVARCHAR);
print'Error message' + CAST(Error_State() AS NVARCHAR);
print'==================================='
end catch
end
