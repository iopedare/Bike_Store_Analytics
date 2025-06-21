BEGIN;

-- Create schemas if they don't exist
CREATE SCHEMA IF NOT EXISTS sales;
CREATE SCHEMA IF NOT EXISTS production;

-- ----------------------------------------------------
-- sales.stores Table
-- ----------------------------------------------------
CREATE TABLE IF NOT EXISTS sales.stores (
    store_id SERIAL PRIMARY KEY,
    store_name VARCHAR (255) NOT NULL,
    phone VARCHAR (25),
    email VARCHAR (255),
    street VARCHAR (255),
    city VARCHAR (255),
    state VARCHAR (10),
    zip_code VARCHAR (5)
);

-- ----------------------------------------------------
-- sales.customers Table
-- ----------------------------------------------------
CREATE TABLE IF NOT EXISTS sales.customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR (255) NOT NULL,
    last_name VARCHAR (255) NOT NULL,
    phone VARCHAR (25),
    email VARCHAR (255) NOT NULL,
    street VARCHAR (255),
    city VARCHAR (50),
    state VARCHAR (25),
    zip_code VARCHAR (5)
);

-- ----------------------------------------------------
-- production.categories Table
-- ----------------------------------------------------
CREATE TABLE IF NOT EXISTS production.categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR (255) NOT NULL
);

-- ----------------------------------------------------
-- production.brands Table
-- ----------------------------------------------------
CREATE TABLE IF NOT EXISTS production.brands (
    brand_id SERIAL PRIMARY KEY,
    brand_name VARCHAR (255) NOT NULL
);

-- ----------------------------------------------------
-- sales.staffs Table
-- ----------------------------------------------------
CREATE TABLE IF NOT EXISTS sales.staffs (
    staff_id SERIAL PRIMARY KEY,
    first_name VARCHAR (50) NOT NULL,
    last_name VARCHAR (50) NOT NULL,
    email VARCHAR (255) NOT NULL UNIQUE,
    phone VARCHAR (25),
    active SMALLINT NOT NULL,
    store_id INT NOT NULL,
    manager_id INT
);

-- ----------------------------------------------------
-- production.products Table
-- ----------------------------------------------------
CREATE TABLE IF NOT EXISTS production.products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR (255) NOT NULL,
    brand_id INT NOT NULL,
    category_id INT NOT NULL,
    model_year SMALLINT NOT NULL,
    list_price NUMERIC (10, 2) NOT NULL
);

-- ----------------------------------------------------
-- sales.orders Table
-- ----------------------------------------------------
CREATE TABLE IF NOT EXISTS sales.orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT,
    order_status SMALLINT NOT NULL,
    order_date DATE NOT NULL,
    required_date DATE NOT NULL,
    shipped_date DATE,
    store_id INT NOT NULL,
    staff_id INT NOT NULL
);

-- ----------------------------------------------------
-- sales.order_items Table
-- ----------------------------------------------------
CREATE TABLE IF NOT EXISTS sales.order_items(
    order_id INT,
    item_id INT,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    list_price NUMERIC (10, 2) NOT NULL,
    discount NUMERIC (4, 2) NOT NULL DEFAULT 0,
    PRIMARY KEY (order_id, item_id)
);

-- ----------------------------------------------------
-- production.stocks Table
-- ----------------------------------------------------
CREATE TABLE IF NOT EXISTS production.stocks (
    store_id INT,
    product_id INT,
    quantity INT,
    PRIMARY KEY (store_id, product_id)
);

-- ----------------------------------------------------
-- Add Foreign Key Constraints
-- ----------------------------------------------------

-- sales.staffs Foreign Keys
ALTER TABLE sales.staffs
    ADD CONSTRAINT fk_staffs_store_id FOREIGN KEY (store_id)
    REFERENCES sales.stores (store_id)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE sales.staffs
    ADD CONSTRAINT fk_staffs_manager_id FOREIGN KEY (manager_id)
    REFERENCES sales.staffs (staff_id)
    ON DELETE NO ACTION ON UPDATE NO ACTION;

-- production.products Foreign Keys
ALTER TABLE production.products
    ADD CONSTRAINT fk_products_category_id FOREIGN KEY (category_id)
    REFERENCES production.categories (category_id)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE production.products
    ADD CONSTRAINT fk_products_brand_id FOREIGN KEY (brand_id)
    REFERENCES production.brands (brand_id)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- sales.orders Foreign Keys
ALTER TABLE sales.orders
    ADD CONSTRAINT fk_orders_customer_id FOREIGN KEY (customer_id)
    REFERENCES sales.customers (customer_id)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE sales.orders
    ADD CONSTRAINT fk_orders_store_id FOREIGN KEY (store_id)
    REFERENCES sales.stores (store_id)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE sales.orders
    ADD CONSTRAINT fk_orders_staff_id FOREIGN KEY (staff_id)
    REFERENCES sales.staffs (staff_id)
    ON DELETE NO ACTION ON UPDATE NO ACTION;

-- sales.order_items Foreign Keys
ALTER TABLE sales.order_items
    ADD CONSTRAINT fk_order_items_order_id FOREIGN KEY (order_id)
    REFERENCES sales.orders (order_id)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE sales.order_items
    ADD CONSTRAINT fk_order_items_product_id FOREIGN KEY (product_id)
    REFERENCES production.products (product_id)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- production.stocks Foreign Keys
ALTER TABLE production.stocks
    ADD CONSTRAINT fk_stocks_store_id FOREIGN KEY (store_id)
    REFERENCES sales.stores (store_id)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE production.stocks
    ADD CONSTRAINT fk_stocks_product_id FOREIGN KEY (product_id)
    REFERENCES production.products (product_id)
    ON DELETE CASCADE ON UPDATE CASCADE;


END;