-- Parte 1: Sentencias

-- 16 Listar los clientes que han gastado más de $500 en total
select nombre, apellido, MontoTotal from clientes c inner join pedidos p on c.ID = p.ClienteID where MontoTotal >= 500;

-- 12 Obtener el total de pedidos y el monto total por año
select year(FechaPedido) as anio, sum(MontoTotal) as total_ventas from pedidos p where FechaPedido between '1900-01-01' and '2024-12-31' group by year(FechaPedido);

-- 15 Obtener el nombre del cliente que más ha gastado
select nombre, apellido, sum(p.MontoTotal) as 'Total Gastado' from clientes c inner join pedidos p on c.ID = p.ClienteID group by c.ID, c.Nombre, c.Apellido order by 'Total Gastado' desc limit 1;

-- 23 Obtener el total de ingresos por mes
select year(FechaPedido) as 'Año', month(FechaPedido) as Numero_Mes, date_format(FechaPedido, '%M') as Nombre_Mes, sum(MontoTotal) as Total_Ingresos from pedidos group by year(FechaPedido), month(FechaPedido), date_format(FechaPedido, '%M') order by	'Año' asc, Numero_Mes asc;

-- 24 Mostrar los clientes cuyo nombre contiene la letra “A”
select * from clientes c where nombre like '%a%';

-- 29 Obtener el total de productos vendidos en cada pedido
select p.id as 'ID del Pedido', p.fechapedido as 'Fecha del Pedido', sum(dp.cantidad) as 'Total de Productos Vendidos' from pedidos p join detallepedidos dp on p.id = dp.pedidoid group by p.id, p.fechapedido
order by p.id;

-- Parte 2: Vistas

-- 37 Crear una vista que liste los 10 productos más vendidos con su categoría
create or replace view diez_mas_vendidos as
select p.ID, NombreProducto as Nombre_Producto, sum(d.Cantidad) as Cantidad_Vendida, c.NombreCategoria from productos p inner join detallepedidos d on p.ID = d.ProductoID join productoscategorias pc on p.ID = pc.ProductoID join categorias c on c.ID = pc.CategoriaID group by p.ID, Nombre_Producto, c.NombreCategoria order by Cantidad_Vendida desc limit 10;
select * from diez_mas_vendidos dmv;

-- 43 Crear una vista que muestre el cliente que más ha gastado en total
create or replace view cliente_mas_gasto as
select c.nombre, c.apellido, sum(p.MontoTotal) as Gastos_Totales from clientes c inner join pedidos p on p.ClienteID = c.ID group by c.id order by Gastos_Totales desc limit 1;
select * from cliente_mas_gasto cmg;

-- Parte 3: Procedimientos

-- 48 Crear un procedimiento que reciba el ID de un producto y devuelva su stock

delimiter //
drop procedure if exists stock_producto;
create procedure stock_producto(in id_producto int)
begin
    declare
        producto_existe int;

    select count(*) into producto_existe
    from productos
    where id = id_producto;

    if producto_existe = 0 then
        signal sqlstate '45000'
            set message_text = 'Error: El producto especificado no existe.';
    else
        select NombreProducto, Stock from productos p where ID = id_producto;
    end if;
end //

call stock_producto(9);

-- 53 Crear un procedimiento que actualice los datos de un cliente

delimiter //
drop procedure if exists actualizar_cliente;
create procedure actualizar_cliente(in id_cliente int, in nombre_cliente varchar(100), in apellido_cliente varchar(100), in email_cliente varchar(100), in tel varchar(20), in fecha_reg date)
begin
    declare
        cliente_existe int;

    select count(*) into cliente_existe
    from clientes
    where id = id_cliente;

    if cliente_existe = 0 then
        signal sqlstate '45000'
            set message_text = 'Error: El cliente especificado no existe.';
    else
        update clientes set Nombre = coalesce(nombre_cliente, Nombre) , Apellido = coalesce(apellido_cliente, Apellido), Email = coalesce(email_cliente, Email), Telefono = coalesce(tel, Telefono), FechaRegistro = coalesce(fecha_reg, FechaRegistro) where ID= id_cliente;
    end if;
end //

call actualizar_cliente(12, null, null, null, null, '1999-10-02');
select * from clientes where ID= 12;
