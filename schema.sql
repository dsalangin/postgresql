CREATE DATABASE testProject;

CREATE TABLE orders
(
  order_number integer PRIMARY KEY,
  client varchar(128) NOT NULL,
  order_price integer NOT NULL
);

CREATE TABLE orderItems
(
  item_id integer PRIMARY KEY,
  product_code integer NOT NULL,
  amount integer NOT NULL,
  price integer  NOT NULL,
  order_number integer REFERENCES orders(order_number) NOT NULL
);

INSERT INTO orders (order_number, client, order_price)
VALUES (generate_series(0, 100000), md5(random()::text), trunc(random()* 700 * 3 * 4 * 5));

INSERT INTO orderItems (item_id, product_code, amount, price, order_number)
VALUES (generate_series(1, 400000), trunc(random()* 443 * 3), trunc(random()*10), trunc(random()* 700 * 3), trunc(random()*100000));

CREATE INDEX idx_orderItems_order_number ON orderItems(order_number);

CREATE FUNCTION get_order_data(order_num integer) RETURNS TABLE (j json) AS $$
  SELECT json_build_object(
    'order_number', order_number,
    'client', client,
    'order_price', order_price,
    'order_items', (
      SELECT json_agg(row_to_json(x))
      FROM (
        SELECT product_code, amount, price
        FROM orderItems 
        WHERE order_number = order_num
      ) x
    )
  )
  FROM orders 
  WHERE orders.order_number = order_num
$$ LANGUAGE SQL;

SELECT  get_order_data(8888);