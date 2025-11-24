select distinct 
ci.cst_gndr,
ca.gen,
case when ci.cst_gndr !='n/a' then ci.cst_gndr---CRM is the master for gender
else coalesce(ca.gen,'n/a')
end as gender
from silver.crm_cust_info ci
left join silver.erp_cust_az12 ca
on ci.cst_key=ca.cid
left join silver.erp_loc_a101 la
on ci.cst_key=la.cid
order by 1,2


---Foreign key Integrity(Dimensions)
select * from gold.fact_sales f
left join gold.dim_customers c
on c.customer_key=f.customer_key
where c.customer_key is null


select * from gold.fact_sales f
left join gold.dim_products p
on p.product_key=f.product_key
where p.product_key is null
