-- 1
select * from clientes c order by FechaRegistro asc;

-- 2
select c.Nombre, count(*) as Total_Pedidos from pedidos p inner join clientes c on p.ClienteID = c.ID group by ClienteID having count(*) > 3;

-- 3
select c.Nombre, count(*) as Total_Pedidos from pedidos p inner join clientes c on p.ClienteID = c.ID group by ClienteID;

-- 4
select NombreProducto from productos p where Stock <= 10;

-- 5
select NombreProducto, Precio from productos p order by Precio desc limit 5;

-- 6
select c.Nombre, count(*) as Total_Pedidos from pedidos p inner join clientes c on p.ClienteID = c.ID group by ClienteID having count(*) = 0;
-- 7
select c.Nombre, sum(MontoTotal) as Total_Gastado from pedidos p inner join clientes c on p.ClienteID = c.ID group by c.ID;

-- 8
select c.Nombre, FechaPedido from pedidos p inner join clientes c on p.ClienteID = c.ID  where FechaPedido >= DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY) order by FechaPedido;

-- 9
select detallepedidos.ID, PedidoID, ProductoID, Cantidad, PrecioUnitario from detallepedidos inner join pedidos p on detallepedidos.PedidoID = p.ID where ClienteID = 1;

-- 10
select NombreProducto, count(*) as Total_Categorias from productoscategorias inner join productos p on productoscategorias.ProductoID = p.ID group by ProductoID having count(*) > 1;

-- 11
select * from pedidos where FechaPedido between '2023-12-31' and '2024-12-31';

-- 12
select year(FechaPedido) as anio, sum(MontoTotal) as total_ventas from pedidos p where FechaPedido between '1900-01-01' and '2024-12-31' group by year(FechaPedido);

-- 13
select NombreProducto, count(ProductoID) from detallepedidos dp inner join productos p on dp.ProductoID = p.ID group by ProductoID having count(ProductoID) >= 5;

-- 14
select NombreCategoria, sum(Stock) as Total_Stock from productos inner join productoscategorias p on productos.ID = p.ProductoID join tp2.categorias c on c.ID = p.CategoriaID group by CategoriaID;

-- 15
select nombre, apellido, sum(p.MontoTotal) as 'Total Gastado' from clientes c inner join pedidos p on c.ID = p.ClienteID group by c.ID, c.Nombre, c.Apellido order by 'Total Gastado' desc limit 1;

-- 16
select nombre, apellido, MontoTotal from clientes c inner join pedidos p on c.ID = p.ClienteID where MontoTotal >= 500;

-- 17
select PedidoID, count(PedidoID) as Total_Productos from detallepedidos group by PedidoID order by count(PedidoID) desc;

-- 18
select MontoTotal from pedidos p order by MontoTotal desc limit 1;

-- 19
select NombreProducto, Precio from productos p where Precio between '50' and '100';

-- 20
select * from pedidos p where MontoTotal > (select avg(MontoTotal) from pedidos) order by MontoTotal asc;

-- 21
select p.ID, p.NombreProducto, p.Precio, p.Stock from productos p left join detallepedidos dp on p.ID = dp.ProductoID left join tp2.productoscategorias p2 on p.ID = p2.ProductoID left join tp2.categorias c on c.ID = p2.CategoriaID where dp.ProductoID is null;

-- 22
SELECT
    c.ID AS CategoriaID,
    c.NombreCategoria,
    p.ID AS ProductoID,
    p.NombreProducto,
    COALESCE(SUM(dp.Cantidad), 0) AS TotalVendido
FROM
    Categorias c
        JOIN
    ProductosCategorias pc ON c.ID = pc.CategoriaID
        JOIN
    Productos p ON pc.ProductoID = p.ID
        LEFT JOIN
    DetallePedidos dp ON p.ID = dp.ProductoID
GROUP BY
    c.ID, c.NombreCategoria, p.ID, p.NombreProducto
HAVING
    TotalVendido = (
        SELECT MAX(Total)
        FROM (
                 SELECT COALESCE(SUM(dp2.Cantidad), 0) AS Total
                 FROM Productos p2
                          LEFT JOIN DetallePedidos dp2 ON p2.ID = dp2.ProductoID
                          JOIN ProductosCategorias pc2 ON p2.ID = pc2.ProductoID
                 WHERE pc2.CategoriaID = c.ID
                 GROUP BY p2.ID
             ) AS Subquery
    )
ORDER BY
    c.ID, TotalVendido DESC;

-- 23


-- 24
select * FROM Clientes WHERE Nombre LIKE '%A%';

-- 25
select * from pedidos p where MontoTotal between  '100' and '200'

-- 26
select ClienteID, count(ClienteID) as Total_Pedidos from pedidos group by ClienteID order by Total_Pedidos desc limit 3;

-- 27
select * from Productos where NombreProducto like 'P%';

-- 28
select * from detallepedidos dp inner join tp2.pedidos p on dp.PedidoID = p.ID where p.FechaPedido >= DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY);

-- 29
select