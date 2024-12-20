INSERT INTO Categories (CategoryName, Description) VALUES
    ('Спиннинги', 'Товары для спортивной рыбалки'),
    ('Удилища', 'Рыболовные снасти'),
    ('Приманки', 'Различные приманки на хищника и бель'),
    ('Катушки', 'Катушки и аксессуары к спиннингам'),
    ('Воблёры', 'Искусственные приманки');

INSERT INTO Products (Name, CategoryID, Price, StockQuantity, Description) VALUES
    ('Спиннинг Major Craft Vierra тест: 20-56г', 1, 17990, 7, 'Потрясающий спиннинг с средним тестом для любителей рыбалки'),
    ('Удилище Penn Overseas Pilk', 2, 27000, 5, 'Профессиональное удилище для любителей морской рыбалки'),
    ('Опарыши 100г', 3, 300, 50, 'Классическая приманка на все случаи жизни'),
    ('Катушка SHIMANO Ultegra', 4, 30000, 3, 'Качестванная катушка, которая подойдёт и новичкам и профессионалам'),
    ('Воблёр Bomber', 5, 1500, 30, 'Премиум воблёр');

INSERT INTO Roles (RoleID, RoleName, Description) VALUES
    (1, 'Admin', 'Администратор с полным доступом'),
    (2, 'Editor', 'Редактор с доступом к управлению контентом'),
    (3, 'Customer', 'Клиент, покупающий товары');

INSERT INTO Users (Username, Email, PasswordHash, RoleID, RegistrationDate, LastLoginDate, IsActive) VALUES
    ('admin', 'admin', 'admin', 1, '2024-03-01', '2024-12-03', true);

