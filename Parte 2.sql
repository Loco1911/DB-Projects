-- 16. Listar los clientes que han gastado más de $500 en total
SELECT c.*, SUM(p.MontoTotal) as TotalGastado
FROM Clientes c
         JOIN Pedidos p ON c.ID = p.ClienteID
GROUP BY c.ID
HAVING TotalGastado > 500;

-- 17. Mostrar la cantidad de productos diferentes vendidos en cada pedido
SELECT p.ID as PedidoID, p.FechaPedido, COUNT(DISTINCT dp.ProductoID) as ProductosDiferentes
FROM Pedidos p
         JOIN DetallePedidos dp ON p.ID = dp.PedidoID
GROUP BY p.ID, p.FechaPedido;

-- 18. Obtener el pedido con mayor monto total
SELECT p.*, c.Nombre, c.Apellido
FROM Pedidos p
         JOIN Clientes c ON p.ClienteID = c.ID
WHERE p.MontoTotal = (SELECT MAX(MontoTotal) FROM Pedidos);

-- 19. Listar los productos cuyo precio está entre $50 y $100
SELECT *
FROM Productos
WHERE Precio BETWEEN 50 AND 100;

-- 20. Mostrar los clientes que han hecho pedidos cuyo monto total es mayor al promedio
SELECT DISTINCT c.*
FROM Clientes c
         JOIN Pedidos p ON c.ID = p.ClienteID
WHERE p.MontoTotal > (SELECT AVG(MontoTotal) FROM Pedidos);

-- 21. Listar los productos que no han sido vendidos
SELECT p.*
FROM Productos p
         LEFT JOIN DetallePedidos dp ON p.ID = dp.ProductoID
WHERE dp.ID IS NULL;

-- 22. Mostrar el producto más vendido de cada categoría
WITH ProductosVendidos AS (
    SELECT p.ID, p.NombreProducto, c.ID as CategoriaID,
           c.NombreCategoria, SUM(dp.Cantidad) as TotalVendido,
           RANK() OVER (PARTITION BY c.ID ORDER BY SUM(dp.Cantidad) DESC) as rn
    FROM Productos p
             JOIN ProductosCategorias pc ON p.ID = pc.ProductoID
             JOIN Categorias c ON pc.CategoriaID = c.ID
             JOIN DetallePedidos dp ON p.ID = dp.ProductoID
    GROUP BY p.ID, p.NombreProducto, c.ID, c.NombreCategoria
)
SELECT NombreCategoria, NombreProducto, TotalVendido
FROM ProductosVendidos
WHERE rn = 1;

-- 23. Obtener el total de ingresos por mes
SELECT YEAR(FechaPedido) as Año,
       MONTH(FechaPedido) as Mes,
       SUM(MontoTotal) as TotalIngresos
FROM Pedidos
GROUP BY YEAR(FechaPedido), MONTH(FechaPedido)
ORDER BY Año, Mes;

-- 24. Mostrar los clientes cuyo nombre contiene la letra "A"
SELECT *
FROM Clientes
WHERE Nombre LIKE '%A%' OR Apellido LIKE '%A%';

-- 25. Listar los pedidos cuyo total sea mayor que $100 y menor que $200
SELECT *
FROM Pedidos
WHERE MontoTotal BETWEEN 100 AND 200;

-- 26. Obtener los 3 clientes que hicieron más pedidos
SELECT c.*, COUNT(p.ID) as TotalPedidos
FROM Clientes c
         JOIN Pedidos p ON c.ID = p.ClienteID
GROUP BY c.ID
ORDER BY TotalPedidos DESC
LIMIT 3;

-- 27. Listar los productos cuyo nombre empieza con "P"
SELECT *
FROM Productos
WHERE NombreProducto LIKE 'P%';

-- 28. Mostrar los detalles de los pedidos realizados en el último mes
SELECT dp.*, p.FechaPedido, pr.NombreProducto
FROM DetallePedidos dp
         JOIN Pedidos p ON dp.PedidoID = p.ID
         JOIN Productos pr ON dp.ProductoID = pr.ID
WHERE p.FechaPedido >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH);

-- 29. Obtener el total de productos vendidos en cada pedido
SELECT p.ID as PedidoID, p.FechaPedido,
       SUM(dp.Cantidad) as TotalProductos
FROM Pedidos p
         JOIN DetallePedidos dp ON p.ID = dp.PedidoID
GROUP BY p.ID, p.FechaPedido;

-- 30. Mostrar los clientes que realizaron más de un pedido el mismo día
SELECT c.*, p.FechaPedido, COUNT(*) as PedidosEnElDia
FROM Clientes c
         JOIN Pedidos p ON c.ID = p.ClienteID
GROUP BY c.ID, p.FechaPedido
HAVING COUNT(*) > 1;