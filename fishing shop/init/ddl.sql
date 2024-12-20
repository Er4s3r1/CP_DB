CREATE TABLE Roles (
    RoleID SERIAL PRIMARY KEY,
    RoleName VARCHAR(50) NOT NULL UNIQUE,
    Description TEXT
);

CREATE TABLE Users (
    UserID SERIAL PRIMARY KEY,
    Username VARCHAR(50) NOT NULL UNIQUE,
    Email VARCHAR(100) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    RoleID INT NOT NULL REFERENCES Roles(RoleID),
    RegistrationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    LastLoginDate TIMESTAMP,
    IsActive BOOLEAN DEFAULT TRUE
);

CREATE TABLE Categories (
    CategoryID SERIAL PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL UNIQUE,
    Description TEXT
);

CREATE TABLE Products (
    ProductID SERIAL PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    CategoryID INT NOT NULL REFERENCES Categories(CategoryID),
    Price NUMERIC(10, 2) NOT NULL,
    StockQuantity INT NOT NULL,
    Description TEXT
);

CREATE TABLE Orders (
    OrderID SERIAL PRIMARY KEY,
    UserID INT NOT NULL REFERENCES Users(UserID),
    OrderDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    TotalAmount NUMERIC(10, 2) NOT NULL,
    OrderStatus VARCHAR(50) DEFAULT 'Обрабатывается'
);

CREATE TABLE OrderDetails (
    OrderDetailID SERIAL PRIMARY KEY,
    OrderID INT NOT NULL REFERENCES Orders(OrderID),
    ProductID INT NOT NULL REFERENCES Products(ProductID),
    Quantity INT NOT NULL,
    Price NUMERIC(10, 2) NOT NULL
);


CREATE OR REPLACE PROCEDURE bulk_add_products(p_json_data json)
LANGUAGE plpgsql AS $$
DECLARE
    r_product RECORD;
BEGIN
    FOR r_product IN
        SELECT * FROM json_populate_recordset(NULL::products, p_json_data)
    LOOP
        BEGIN
            INSERT INTO products (name, description, price, stockquantity, categoryid)
            VALUES (r_product.name, r_product.description, r_product.price, r_product.stockquantity, r_product.categoryid);
        EXCEPTION
            WHEN OTHERS THEN
                RAISE NOTICE 'Ошибка при добавлении продукта: %', r_product.name;
        END;
    END LOOP;
END;
$$;

CREATE OR REPLACE FUNCTION get_orders_summary_for_all_users(
    p_start_date DATE,
    p_end_date DATE
)
RETURNS TABLE (
    UserID INT,
    UserName TEXT,
    total_orders BIGINT,
    total_amount NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        u.UserID,
        u.Username,
        COUNT(o.OrderID) AS total_orders,
        SUM(o.TotalAmount) AS total_amount
    FROM
        Users u
    LEFT JOIN Orders o ON u.UserID = o.UserID
    WHERE o.OrderDate BETWEEN p_start_date AND p_end_date
    AND o.OrderStatus = 'доставлен'
    GROUP BY u.UserID, u.Username
    ORDER BY total_amount DESC;
END;
$$ LANGUAGE plpgsql;

CREATE VIEW OrderDetailsView AS
SELECT
    o.OrderID,
    o.UserID,
    o.OrderDate,
    o.OrderStatus,
    o.TotalAmount,
    od.ProductID,
    p.Name AS ProductName,
    od.Quantity,
    od.Price
FROM Orders o
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID;

CREATE OR REPLACE FUNCTION check_stock() RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT stockquantity FROM products WHERE productid = NEW.productid) < NEW.quantity THEN
        RAISE EXCEPTION 'Недостаточное количество товара на складе';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_stock_trigger
BEFORE INSERT ON orderdetails
FOR EACH ROW
EXECUTE FUNCTION check_stock();