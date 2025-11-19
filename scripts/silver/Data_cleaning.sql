---check for Nulls or Duplicates in Primary Key
---Expectation: No Resullt
 Select cst_id, count(*) 
 from silver.crm_cust_info
 group by cst_id
 having count(*) >1;

 ---check for unwanted spaces
 ---Expectation: no result
 select cst_firstname
 from silver.crm_cust_info
 where cst_firstname !=trim(cst_firstname);

 ---data standardization & consistency
  select distinct cst_marital_status
 from silver.crm_cust_info;

 ---check for Nulls or Duplicates in Primary Key
---Expectation: No Resullt
 Select prd_id, count(*) 
 from silver.crm_prd_info
 group by prd_id
 having count(*) >1;

  ---check for unwanted spaces
 ---Expectation: no result
 select prd_nm
 from bronze.crm_prd_info
 where prd_nm !=trim(prd_nm);

  ---check for Nulls or Negative numbers in 
---Expectation: No Resullt
 Select prd_cost 
 from bronze.crm_prd_info
 where prd_cost<0 or prd_cost is null;

 
 ---data standardization & consistency
  select distinct prd_line
 from bronze.crm_prd_info;

 ---Check for invalid date orders
 select * from bronze.crm_prd_info
 where prd_start_dt> prd_end_dt 

 ---check for invalid date
 select nullif(sls_order_dt,0) from bronze.crm_sales_details
 where sls_order_dt <=0 or len(sls_order_dt) !=8 or sls_order_dt> 20500101

 ---check for invalid date
 select * from bronze.crm_sales_details
 where sls_order_dt>sls_ship_dt or sls_order_dt>sls_due_dt;

 ---check data consistency:betweebn sales,quality and price
 ---sales= Quantity*price
 ---values must not br zero,null or negative

 select distinct sls_sales as old_sls_sales,
 sls_quantity,
 sls_price as ols_sls_price,
 case when sls_sales is null or sls_sales<=0 or sls_sales!=sls_quantity * ABS(sls_price)
 Then sls_quantity * ABS(sls_price)
 Else  sls_sales
 end as sls_sales,
 case when sls_price is null or sls_price<=0
 then sls_sales/nullif (sls_quantity,0) 
 else sls_price
 end as sls_price
 from Bronze.crm_sales_details
 where sls_sales != sls_quantity * sls_price
 or sls_sales is null or sls_quantity is null or sls_price is null
 or sls_sales <=0 or sls_quantity <=0 or sls_price<=0
 order by sls_sales,sls_quantity,sls_price;

  select distinct sls_sales,
 sls_quantity,
 sls_price
 from silver.crm_sales_details
  where sls_sales != sls_quantity * sls_price
 or sls_sales is null or sls_quantity is null or sls_price is null
 or sls_sales <=0 or sls_quantity <=0 or sls_price<=0
 order by sls_sales,sls_quantity,sls_price;

 ---cleaning cid
 select cid,
case when cid like 'NAS%' then substring(cid, 4, len(cid))
else cid
end cid,
bdate, 
gen
from Bronze.erp_cust_az12
where case when cid like 'NAS%' then substring(cid, 4, len(cid))
else cid
end 
  not in(select distinct cst_key from silver.crm_cust_info)



 ---identify out of range dates
 select distinct bdate from Bronze.erp_cust_az12
 where bdate< '1924-01-01' or bdate> getdate()

 

 ----data standardization & consistency
 select distinct gen,
 case when upper(trim(gen)) in ('F','FEMALE') then 'Female'
when upper(trim(gen)) in ('M','MALE') then 'Male'
  else 'n/a'
  end as gen
 from Bronze.erp_cust_az12

 ----Data standardization & consistency
select distinct cntry as old_cntry,
case when trim(cntry)= 'DE' then 'Germany'
when trim(cntry) in ('US','USA') then 'United States'
when trim(cntry)='' or cntry is null then 'n/a'
else trim(cntry)
end as cntry 
from Bronze.erp_loc_a101

---check for unwanted spaces
select * from bronze.erp_px_cat_g1v2
where cat != trim(cat) or subcat != trim(subcat) or maintenance != trim(maintenance)

---data standardization & consistency
select distinct maintenance  from bronze.erp_px_cat_g1v2
