BEGIN;

-- -------------------------------------------------------------------
-- Load independent tables (Level 0)
-- These tables do not have foreign keys referencing other production tables yet.
-- -------------------------------------------------------------------

-- Load sales.customers
INSERT INTO sales.customers (customer_id, first_name, last_name, phone, email, street, city, state, zip_code)
SELECT
    customer_id::INTEGER,
    first_name,
    last_name,
    NULLIF(phone, ''), -- Convert empty string to NULL
    email,
    NULLIF(street, ''),
    NULLIF(city, ''),
    NULLIF(state, ''),
    NULLIF(zip_code, '')
FROM staging.customers
ON CONFLICT (customer_id) DO NOTHING; -- Prevents re-inserting if customer_id already exists

-- Load sales.stores
INSERT INTO sales.stores (store_id, store_name, phone, email, street, city, state, zip_code)
SELECT
    store_id::INTEGER,
    store_name,
    NULLIF(phone, ''),
    NULLIF(email, ''),
    NULLIF(street, ''),
    NULLIF(city, ''),
    NULLIF(state, ''),
    NULLIF(zip_code, '')
FROM staging.stores
ON CONFLICT (store_id) DO NOTHING;

-- Load production.categories
INSERT INTO production.categories (category_id, category_name)
SELECT
    category_id::INTEGER,
    category_name
FROM staging.categories
ON CONFLICT (category_id) DO NOTHING;

-- Load production.brands
INSERT INTO production.brands (brand_id, brand_name)
SELECT
    brand_id::INTEGER,
    brand_name
FROM staging.brands
ON CONFLICT (brand_id) DO NOTHING;


-- -------------------------------------------------------------------
-- Load tables dependent on Level 0 tables
-- -------------------------------------------------------------------

-- Load sales.staffs
-- Depends on sales.stores. Also has a self-referencing manager_id.
INSERT INTO sales.staffs (staff_id, first_name, last_name, email, phone, active, store_id, manager_id)
SELECT
    staff_id::INTEGER,
    first_name,
    last_name,
    email,
    NULLIF(phone, ''),
    active::SMALLINT,
    store_id::INTEGER,
    manager_id::INTEGER
FROM staging.staffs
ON CONFLICT (staff_id) DO NOTHING;


-- Load production.products
-- Depends on production.brands and production.categories.
INSERT INTO production.products (product_id, product_name, brand_id, category_id, model_year, list_price)
SELECT
    product_id::INTEGER,
    product_name,
    brand_id::SMALLINT,
    category_id::SMALLINT,
    model_year::SMALLINT,
    list_price::NUMERIC(10, 2)
FROM staging.products
ON CONFLICT (product_id) DO NOTHING;


-- -------------------------------------------------------------------
-- Load tables dependent on Level 0 & 1 tables
-- -------------------------------------------------------------------

-- Load sales.orders
-- Depends on sales.customers, sales.stores, sales.staffs.
INSERT INTO sales.orders (order_id, customer_id, order_status, order_date, required_date, shipped_date, store_id, staff_id)
SELECT
    order_id::INTEGER,
    customer_id::INTEGER,
    order_status::SMALLINT,
    order_date::DATE,
    required_date::DATE,
    shipped_date::DATE,
    store_id::INTEGER,
    staff_id::INTEGER
FROM staging.orders
ON CONFLICT (order_id) DO NOTHING;


-- Load production.stocks
-- Depends on sales.stores and production.products.
INSERT INTO production.stocks (store_id, product_id, quantity)
SELECT
    store_id::INTEGER,
    product_id::INTEGER,
    quantity::INTEGER
FROM staging.stocks
ON CONFLICT (store_id, product_id) DO NOTHING; -- Assuming PK is (store_id, product_id)


-- -------------------------------------------------------------------
-- Load tables dependent on Level 2 tables
-- -------------------------------------------------------------------

-- Load sales.order_items
-- Depends on sales.orders and production.products.
INSERT INTO sales.order_items (order_id, item_id, product_id, quantity, list_price, discount)
SELECT
    order_id::INTEGER,
    item_id::INTEGER,
    product_id::INTEGER,
    quantity::INTEGER,
    list_price::NUMERIC(10, 2),
    discount::NUMERIC(4, 2)
FROM staging.order_items
ON CONFLICT (order_id, item_id) DO NOTHING; -- Assuming PK is (order_id, item_id)


-- -------------------------------------------------------------------
-- Finalize Transaction
-- -------------------------------------------------------------------

-- If all steps above were successful, commit the transaction.
COMMIT;

-- If any step failed and you want to revert all changes made in this transaction:
-- ROLLBACK;

-- -------------------------------------------------------------------
-- Clean Up Staging Tables (After successful load)
-- -------------------------------------------------------------------

-- Truncate for reuse (faster than DELETE for large tables)
TRUNCATE staging.customers;
TRUNCATE staging.stores;
TRUNCATE staging.staffs;
TRUNCATE staging.categories;
TRUNCATE staging.brands;
TRUNCATE staging.products;
TRUNCATE staging.orders;
TRUNCATE staging.order_items;
TRUNCATE staging.stocks;

-- Drop if no longer needed
