------------------------------------------------------
-- ETL Process (Extract, Transform, Load) 
------------------------------------------------------


-- 1. Load DimCustomer
INSERT INTO sales_dw.DimCustomer(customer_id, first_name, last_name, phone, email, street, city, state, zip_code)
SELECT
	C.customer_id, 
	C.first_name, 
	C.last_name, 
	C.phone, 
	C.email, 
	C.street,
	C.city, 
	C.state, 
	C.zip_code
FROM sales.customers C;


-- 2. Load DimProduct
INSERT INTO sales_dw.DimProduct(product_id, product_name, model_year, category_id, category_name, brand_id, brand_name)
SELECT DISTINCT
	P.product_id,
	P.product_name,
	P.model_year,
	CAT.category_id,
	CAT.category_name,
	B.brand_id,
	B.brand_name
FROM production.products P
JOIN production.categories CAT ON P.category_id = CAT.category_id
JOIN production.brands B ON P.brand_id = B.brand_id;


-- 3. Load DimStore
INSERT INTO sales_dw.DimStore(store_id, store_name, phone, email, street, city, state, zip_code)
SELECT DISTINCT
	S.store_id,
	S.store_name,
	S.phone,
	S.email,
	S.street,
	S.city,
	S.state,
	S.zip_code
FROM sales.stores S;


-- 4. Load DimStaff
INSERT INTO sales_dw.DimStaff(staff_id, first_name, last_name, email, phone, active, store_id, store_name, manager_id, manager_name)
SELECT DISTINCT 
	ST.staff_id,
	ST.first_name,
	ST.last_name,
	ST.email,
	ST.phone,
	-- ST.active, # column "active" is of type boolean but expression is of type smallint
	-- FIX
	CASE
		WHEN ST.active = 1 THEN TRUE
		WHEN ST.active = 0 THEN FALSE
		ELSE FALSE
	END AS active,
	ST.store_id,
	STO.store_name,
	ST.manager_id,
	COALESCE(M.first_name || ' ' || M.last_name, 'N/A')
FROM sales.staffs ST
LEFT JOIN sales.stores STO ON ST.store_id = STO.store_id
LEFT JOIN sales.staffs M ON ST.manager_id = M.staff_id;


-- 5. Load FactSales Table
INSERT INTO sales_dw.FactSales(order_id, product_sk,customer_sk, store_sk, staff_sk, date_sk, quantity, list_price, discount, order_amount, order_status)
SELECT
	O.order_id,
	DP.product_sk,
	DC.customer_sk,
	DSTO.store_sk,
	DST.staff_sk,
	DD.date_sk,
	OI.quantity,
	OI.list_price,
	OI.discount,
	(OI.quantity * OI.list_price * (1 - OI.discount)) AS order_amount,
	O.order_status	
FROM sales.order_items OI
JOIN sales.orders O ON OI.order_id = O.order_id
JOIN sales_dw.DimProduct DP ON OI.product_id = DP.product_id
JOIN sales_dw.DimCustomer DC ON O.customer_id = DC.customer_id
JOIN sales_dw.DimStore DSTO ON O.store_id = DSTO.store_id
JOIN sales_dw.DimStaff DST ON O.staff_id = DST.staff_id
JOIN sales_dw.DimDate DD ON O.order_date = DD.full_date
WHERE O.order_date BETWEEN '2016-01-01' AND '2018-12-31';


