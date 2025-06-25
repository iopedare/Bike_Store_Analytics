-------------------------------------------------
-- Sales Data Warehouse
-------------------------------------------------

BEGIN;


-- 1. Create a schema for data warehouse
CREATE SCHEMA IF NOT EXISTS sales_dw;

-- 2. Create the dimension tables
-- DimDate Table
CREATE TABLE sales_dw.DimDate(
	date_sk INT PRIMARY KEY,
	full_date DATE NOT NULL,
	day_of_week INT NOT NULL,
	day_name VARCHAR(10) NOT NULL,
	day_of_month INT NOT NULL,
	day_of_year INT NOT NULL,
	week_of_year INT NOT NULL,
	month INT NOT NULL,
	month_name VARCHAR(10) NOT NULL,
	quarter INT NOT NULL,
	year INT NOT NULL,
	is_weekend BOOLEAN NOT NULL,
	CONSTRAINT UQ_full_date UNIQUE (full_date)
);


-- DimCustomer Table
CREATE TABLE sales_dw.DimCustomer(
	customer_sk SERIAL PRIMARY KEY,
	customer_id INT NOT NULL,
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	phone VARCHAR(20),
	email VARCHAR(100),
	street VARCHAR(100),
	city VARCHAR(50),
	state VARCHAR(50),
	zip_code VARCHAR(10),
	CONSTRAINT UQ_customer_id UNIQUE (customer_id)
);


-- DimProduct Table
CREATE TABLE sales_dw.DimProduct(
	product_sk SERIAL PRIMARY KEY,
	product_id INT NOT NULL,
	product_name VARCHAR(255),
	model_year INT,
	category_id INT,
	category_name VARCHAR(50),
	brand_id INT,
	brand_name VARCHAR(50),
	CONSTRAINT UQ_product_id UNIQUE (product_id)
);


-- DimStore Table
CREATE TABLE sales_dw.DimStore(
	store_sk SERIAL PRIMARY KEY,
	store_id INT NOT NULL,
	store_name VARCHAR(255),
	phone VARCHAR(20),
	email VARCHAR(100),
	street VARCHAR(100),
	city VARCHAR(50),
	state VARCHAR(50),
	zip_code VARCHAR(10),
	CONSTRAINT UQ_store_id UNIQUE (store_id)
);


-- DimStaff Table
CREATE TABLE sales_dw.DimStaff(
	staff_sk SERIAL PRIMARY KEY,
	staff_id INT NOT NULL,
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	email VARCHAR(100),
	phone VARCHAR(20),
	active BOOLEAN,
	store_id INT,
	store_name VARCHAR(255),
	manager_id INT,
	manager_name VARCHAR(100),
	CONSTRAINT UQ_staff_id UNIQUE (staff_id)
);

-- 3. Create the Fact Table
-- FactSales Table
CREATE TABLE sales_dw.FactSales(
	order_items_sk SERIAL PRIMARY KEY,
	order_id INT NOT NULL,
	product_sk INT NOT NULL,
	customer_sk INT NOT NULL,
	store_sk INT NOT NULL,
	staff_sk INT NOT NULL,
	date_sk INT NOT NULL,
	quantity INT NOT NULL,
	list_price NUMERIC(10, 2) NOT NULL,
	discount NUMERIC(4, 2) NOT NULL,
	order_amount NUMERIC(10, 2) NOT NULL,
	order_status VARCHAR(20) NOT NULL,

	CONSTRAINT FK_FactSales_DimProduct FOREIGN KEY (product_sk) REFERENCES sales_dw.DimProduct(product_sk),
	CONSTRAINT FK_FactSales_DimCustomer FOREIGN KEY (customer_sk) REFERENCES sales_dw.DimCustomer(customer_sk),
	CONSTRAINT FK_FactSales_DimStore FOREIGN KEY (store_sk) REFERENCES sales_dw.DimStore(store_sk),
	CONSTRAINT FK_FactSales_DimStaff FOREIGN KEY (staff_sk) REFERENCES sales_dw.DimStaff(staff_sk),
	CONSTRAINT FK_FactSales_DimDate FOREIGN KEY (date_sk) REFERENCES sales_dw.DimDate(date_sk)
);


-- 4. Add Indexes to Fact Table for reporting performace
CREATE INDEX idx_fact_sales_product_sk ON sales_dw.FactSales(product_sk);
CREATE INDEX idx_fact_sales_customer_sk ON sales_dw.FactSales(customer_sk);
CREATE INDEX idx_fact_sales_store_sk ON sales_dw.FactSales(store_sk);
CREATE INDEX idx_fact_sales_staff_sk ON sales_dw.FactSales(staff_sk);
CREATE INDEX idx_fact_sales_date_sk ON sales_dw.FactSales(date_sk);


-- 5. Populate DimDate Table
INSERT INTO sales_dw.DimDate(date_sk, full_date, day_of_week, day_name, day_of_month, day_of_year, week_of_year, month, month_name, quarter, year, is_weekend)
SELECT 
	TO_CHAR(dt, 'YYYYMMDD')::INT AS date_sk,
	dt AS full_date,
	EXTRACT(DOW FROM dt) AS day_of_week,
	TO_CHAR(dt, 'Day') AS day_name,
	EXTRACT(DAY FROM dt) AS day_of_month,
	EXTRACT(DOY FROM dt) AS day_of_year,
	EXTRACT(WEEK FROM dt) AS week_of_year,
	EXTRACT(MONTH FROM dt) AS month,
	TO_CHAR(dt, 'Month') AS month_name,
	EXTRACT(QUARTER FROM dt)  AS quarter,
	EXTRACT(YEAR FROM dt) AS year,
	CASE WHEN EXTRACT(DOW FROM dt) IN (0, 6) THEN TRUE ELSE FALSE END AS is_weekend
FROM 
	GENERATE_SERIES('2016-01-01'::DATE, '2018-12-31'::DATE, '1 day'::INTERVAL) AS dt
ON CONFLICT (date_sk) DO NOTHING;


END;
