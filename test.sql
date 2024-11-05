create or replace view diez_mas_vendidos as
select p.ID, NombreProducto as Nombre_Producto, sum(d.Cantidad) as Cantidad_Vendida, c.NombreCategoria from productos p inner join detallepedidos d on p.ID = d.ProductoID join productoscategorias pc on p.ID = pc.ProductoID join categorias c on c.ID = pc.CategoriaID group by p.ID, Nombre_Producto, c.NombreCategoria order by Cantidad_Vendida desc limit 10;
select * from diez_mas_vendidos dmv;
