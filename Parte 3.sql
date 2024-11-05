-- Parte 3: Procedimientos Almacenados (15 ejercicios)

-- 1. Procedimiento para obtener pedidos de un cliente
DELIMITER //
CREATE PROCEDURE ObtenerPedidosCliente(IN clienteID INT)
BEGIN
    DECLARE cliente_existe INT;

    SELECT COUNT(*) INTO cliente_existe FROM Clientes WHERE ID = clienteID;

    IF cliente_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: El cliente especificado no existe.';
    ELSE
        SELECT * FROM Pedidos WHERE ClienteID = clienteID;
    END IF;
END //
DELIMITER ;

-- 2. Procedimiento para obtener pedidos por rango de fechas
DELIMITER //
CREATE PROCEDURE ObtenerPedidosPorFecha(IN fechaInicio DATE, IN fechaFin DATE)
BEGIN
    IF fechaInicio > fechaFin THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: La fecha de inicio no puede ser posterior a la fecha de fin.';
    ELSE
        SELECT * FROM Pedidos
        WHERE FechaPedido BETWEEN fechaInicio AND fechaFin;
    END IF;
END //
DELIMITER ;

-- 3. Procedimiento para obtener stock de un producto
DELIMITER //
CREATE PROCEDURE ObtenerStockProducto(IN productoID INT, OUT stockActual INT)
BEGIN
    DECLARE producto_existe INT;

    SELECT COUNT(*) INTO producto_existe FROM Productos WHERE ID = productoID;

    IF producto_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: El producto especificado no existe.';
    ELSE
        SELECT Stock INTO stockActual FROM Productos WHERE ID = productoID;
    END IF;
END //
DELIMITER ;

-- 4. Procedimiento para obtener productos por rango de precios
DELIMITER //
CREATE PROCEDURE ObtenerProductosPorRangoPrecio(IN precioMin DECIMAL(10,2), IN precioMax DECIMAL(10,2))
BEGIN
    IF precioMin > precioMax THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: El precio mínimo no puede ser mayor que el precio máximo.';
    ELSE
        SELECT * FROM Productos
        WHERE Precio BETWEEN precioMin AND precioMax;
    END IF;
END //
DELIMITER ;

-- 5. Procedimiento para actualizar un producto
DELIMITER //
CREATE PROCEDURE ActualizarProducto(
    IN productoID INT,
    IN nuevoNombre VARCHAR(100),
    IN nuevoPrecio DECIMAL(10,2),
    IN nuevoStock INT
)
BEGIN
    DECLARE producto_existe INT;

    SELECT COUNT(*) INTO producto_existe FROM Productos WHERE ID = productoID;

    IF producto_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: El producto especificado no existe.';
    ELSEIF nuevoStock < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: El stock no puede ser negativo.';
    ELSE
        UPDATE Productos
        SET NombreProducto = COALESCE(nuevoNombre, NombreProducto),
            Precio = COALESCE(nuevoPrecio, Precio),
            Stock = COALESCE(nuevoStock, Stock)
        WHERE ID = productoID;
    END IF;
END //
DELIMITER ;

-- 6. Procedimiento para eliminar pedidos de un cliente
DELIMITER //
CREATE PROCEDURE EliminarPedidosCliente(IN clienteID INT)
BEGIN
    DECLARE cliente_existe INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Error: No se pudieron eliminar los pedidos.';
        END;

    SELECT COUNT(*) INTO cliente_existe FROM Clientes WHERE ID = clienteID;

    IF cliente_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: El cliente especificado no existe.';
    ELSE
        START TRANSACTION;
        DELETE FROM DetallePedidos WHERE PedidoID IN (SELECT ID FROM Pedidos WHERE ClienteID = clienteID);
        DELETE FROM Pedidos WHERE ClienteID = clienteID;
        COMMIT;
    END IF;
END //
DELIMITER ;

-- 7. Procedimiento para insertar un nuevo pedido
DELIMITER //
CREATE PROCEDURE InsertarNuevoPedido(
    IN clienteID INT,
    IN fechaPedido DATE,
    IN montoTotal DECIMAL(10,2),
    OUT nuevoPedidoID INT
)
BEGIN
    DECLARE cliente_existe INT;

    SELECT COUNT(*) INTO cliente_existe FROM Clientes WHERE ID = clienteID;

    IF cliente_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: El cliente especificado no existe.';
    ELSEIF montoTotal < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: El monto total no puede ser negativo.';
    ELSE
        INSERT INTO Pedidos (ClienteID, FechaPedido, MontoTotal)
        VALUES (clienteID, COALESCE(fechaPedido, CURDATE()), COALESCE(montoTotal, 0));
        SET nuevoPedidoID = LAST_INSERT_ID();
    END IF;
END //
DELIMITER ;

-- 8. Procedimiento para actualizar datos de un cliente
DELIMITER //
CREATE PROCEDURE ActualizarCliente(
    IN clienteID INT,
    IN nuevoNombre VARCHAR(100),
    IN nuevoApellido VARCHAR(100),
    IN nuevoEmail VARCHAR(100),
    IN nuevoTelefono VARCHAR(20)
)
BEGIN
    DECLARE cliente_existe INT;

    SELECT COUNT(*) INTO cliente_existe FROM Clientes WHERE ID = clienteID;

    IF cliente_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: El cliente especificado no existe.';
    ELSE
        UPDATE Clientes
        SET Nombre = COALESCE(nuevoNombre, Nombre),
            Apellido = COALESCE(nuevoApellido, Apellido),
            Email = COALESCE(nuevoEmail, Email),
            Telefono = COALESCE(nuevoTelefono, Telefono)
        WHERE ID = clienteID;
    END IF;
END //
DELIMITER ;

-- 9. Procedimiento para eliminar un producto
DELIMITER //
CREATE PROCEDURE EliminarProducto(IN productoID INT)
BEGIN
    DECLARE producto_existe INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Error: No se pudo eliminar el producto.';
        END;

    SELECT COUNT(*) INTO producto_existe FROM Productos WHERE ID = productoID;

    IF producto_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: El producto especificado no existe.';
    ELSE
        START TRANSACTION;
        DELETE FROM ProductosCategorias WHERE ProductoID = productoID;
        DELETE FROM DetallePedidos WHERE ProductoID = productoID;
        DELETE FROM Productos WHERE ID = productoID;
        COMMIT;
    END IF;
END //
DELIMITER ;

-- 10. Procedimiento para obtener monto total de pedidos de un cliente DELIMITER //
CREATE PROCEDURE ObtenerMontoTotalPedidosCliente(IN clienteID INT, OUT montoTotal DECIMAL(10,2))
BEGIN
    DECLARE cliente_existe INT;

    SELECT COUNT(*) INTO cliente_existe FROM Clientes WHERE ID = clienteID;

    IF cliente_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: El cliente especificado no existe.';
    ELSE
        SELECT SUM(MontoTotal) INTO montoTotal FROM Pedidos WHERE ClienteID = clienteID;
    END IF;
END //
DELIMITER ;

-- 11. Procedimiento para obtener productos de una categoría
DELIMITER //
CREATE PROCEDURE ObtenerProductosCategoria(IN categoriaID INT)
BEGIN
    DECLARE categoria_existe INT;

    SELECT COUNT(*) INTO categoria_existe FROM Categorias WHERE ID = categoriaID;

    IF categoria_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: La categoría especificada no existe.';
    ELSE
        SELECT p.* FROM Productos p
                            JOIN ProductosCategorias pc ON p.ID = pc.ProductoID
        WHERE pc.CategoriaID = categoriaID;
    END IF;
END //
DELIMITER ;

-- 12. Procedimiento para obtener categorías de un producto
DELIMITER //
CREATE PROCEDURE ObtenerCategoriasProducto(IN productoID INT)
BEGIN
    DECLARE producto_existe INT;

    SELECT COUNT(*) INTO producto_existe FROM Productos WHERE ID = productoID;

    IF producto_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: El producto especificado no existe.';
    ELSE
        SELECT c.* FROM Categorias c
                            JOIN ProductosCategorias pc ON c.ID = pc.CategoriaID
        WHERE pc.ProductoID = productoID;
    END IF;
END //
DELIMITER ;

-- 13. Procedimiento para insertar un nuevo producto
DELIMITER //
CREATE PROCEDURE InsertarNuevoProducto(
    IN nuevoNombre VARCHAR(100),
    IN nuevoPrecio DECIMAL(10,2),
    IN nuevoStock INT,
    OUT nuevoProductoID INT
)
BEGIN
    IF nuevoPrecio < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: El precio no puede ser negativo.';
    ELSEIF nuevoStock < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: El stock no puede ser negativo.';
    ELSE
        INSERT INTO Productos (NombreProducto, Precio, Stock)
        VALUES (nuevoNombre, nuevoPrecio, nuevoStock);
        SET nuevoProductoID = LAST_INSERT_ID();
    END IF;
END //
DELIMITER ;

-- 14. Procedimiento para insertar un nuevo cliente
DELIMITER //
CREATE PROCEDURE InsertarNuevoCliente(
    IN nuevoNombre VARCHAR(100),
    IN nuevoApellido VARCHAR(100),
    IN nuevoEmail VARCHAR(100),
    IN nuevoTelefono VARCHAR(20),
    OUT nuevoClienteID INT
)
BEGIN
    INSERT INTO Clientes (Nombre, Apellido, Email, Telefono, FechaRegistro)
    VALUES (nuevoNombre, nuevoApellido, nuevoEmail, nuevoTelefono, CURDATE());
    SET nuevoClienteID = LAST_INSERT_ID();
END //
DELIMITER ;

-- 15. Procedimiento para eliminar un cliente
DELIMITER //
CREATE PROCEDURE EliminarCliente(IN clienteID INT)
BEGIN
    DECLARE cliente_existe INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Error: No se pudo eliminar el cliente.';
        END;

    SELECT COUNT(*) INTO cliente_existe FROM Clientes WHERE ID = clienteID;

    IF cliente_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: El cliente especificado no existe.';
    ELSE
        START TRANSACTION;
        DELETE FROM Pedidos WHERE ClienteID = clienteID;
        DELETE FROM Clientes WHERE ID = clienteID;
        COMMIT;
    END IF;
END //
DELIMITER ;