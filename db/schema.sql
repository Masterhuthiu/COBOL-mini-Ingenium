CREATE TABLE policy (
    policy_id SERIAL PRIMARY KEY,
    customer_name TEXT,
    product_code TEXT,
    base_premium NUMERIC,
    status TEXT,
    next_bill_date DATE
);

CREATE TABLE rider (
    rider_id SERIAL PRIMARY KEY,
    policy_id INT,
    rider_type TEXT,
    rider_premium NUMERIC
);

CREATE TABLE invoice (
    invoice_id SERIAL PRIMARY KEY,
    policy_id INT,
    amount NUMERIC,
    due_date DATE,
    status TEXT
);