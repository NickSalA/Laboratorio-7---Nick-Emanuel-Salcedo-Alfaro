SET SERVEROUTPUT ON

-- 1 Obtenga el color y ciudad para las partes que no son de París, con un peso mayor de diez.
CREATE OR REPLACE PROCEDURE partes_no_paris IS
BEGIN
    FOR r IN (
        SELECT color, city
        FROM P
        WHERE city <> 'Paris' AND weight > 10
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('COLOR: ' || r.color || ' | CIUDAD: ' || r.city);
    END LOOP;
END;
/

-- 2 Para todas las partes, obtenga el número de parte y el peso de dichas partes en gramos.
-- En la tabla P (Partes) se menciona que asumimos que los pesos estan en libras, Segun lo que busque en Google la conversión de libras a gramos es de que 1 libra equivale a 453.592 gramos
CREATE OR REPLACE PROCEDURE partes_en_gramos IS
BEGIN
    FOR r IN (
        SELECT p#, weight * 453.592 AS peso_gramos
        FROM P
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('PARTE: ' || r.p# || ' | PESO EN GRAMOS: ' || r.peso_gramos);
    END LOOP;
END;
/


-- 3 Obtenga el detalle completo de todos los proveedores.
CREATE OR REPLACE PROCEDURE detalle_proveedores IS
BEGIN
    FOR r IN (
        SELECT * 
        FROM S
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('PROVEEDOR: ' || r.s# || ' - ' || r.sname || ' | ESTADO: ' || r.status || ' | CIUDAD: ' || r.city);
    END LOOP;
END;
/

-- 4 Obtenga todas las combinaciones de proveedores y partes para aquellos proveedores y partes co-localizados.
CREATE OR REPLACE PROCEDURE proveedores_partes_colocalizados IS
BEGIN
    FOR r IN (
        SELECT s.s#, p.p#
        FROM S s
        JOIN P p USING (city)
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('PROVEEDOR: ' || r.s# || ' | PARTE: ' || r.p#);
    END LOOP;
END;
/


-- 5 Obtenga todos los pares de nombres de ciudades de tal forma que el proveedor localizado en la primera ciudad del par abastece una parte almacenada en la segunda ciudad del par.
CREATE OR REPLACE PROCEDURE pares_ciudades IS
BEGIN
    FOR r IN (
        SELECT DISTINCT s.city AS ciudad_proveedor, p.city AS ciudad_parte
        FROM S s
        JOIN SP USING (s#)
        JOIN P USING (p#)
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(r.ciudad_proveedor || ' -> ' || r.ciudad_parte);
    END LOOP;
END;
/


-- 6 Obtenga todos los pares de número de proveedor tales que los dos proveedores del par estén co-localizados.
CREATE OR REPLACE PROCEDURE proveedores_colocalizados IS
BEGIN
    FOR r IN (
        SELECT s1.s# s1_id, s2.s# s2_id
        FROM S s1
        JOIN S s2 ON s1.city = s2.city AND s1.s# < s2.s#
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('(' || r.s1_id || ', ' || r.s2_id || ')');
    END LOOP;
END;
/

-- 7 Obtenga el número total de proveedores.
CREATE OR REPLACE FUNCTION total_proveedores RETURN NUMBER IS
    v_total NUMBER;
BEGIN
    SELECT COUNT(*) 
    INTO v_total FROM S;
    RETURN v_total;
END;
/

-- 8 Obtenga la cantidad mínima y la cantidad máxima para la parte P2.
CREATE OR REPLACE PROCEDURE min_max_p2 IS
    v_min NUMBER;
    v_max NUMBER;
BEGIN
    SELECT MIN(qty), MAX(qty)
    INTO v_min, v_max
    FROM SP
    WHERE p# = 'P2';

    DBMS_OUTPUT.PUT_LINE('MIN: ' || v_min || ' | MAX: ' || v_max);
END;
/

-- 9 Para cada parte abastecida, obtenga el número de parte y el total despachado.
CREATE OR REPLACE PROCEDURE total_por_parte IS
BEGIN
    FOR r IN (
        SELECT p#, SUM(qty) AS total
        FROM SP
        GROUP BY p#
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('PARTE: ' || r.p# || ' | TOTAL: ' || r.total);
    END LOOP;
END;
/


-- 10 Obtenga el número de parte para todas las partes abastecidas por más de un proveedor.
CREATE OR REPLACE PROCEDURE partes_multiproveedor IS
BEGIN
    FOR r IN (
        SELECT p#
        FROM SP
        GROUP BY p#
        HAVING COUNT(DISTINCT s#) > 1
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('PARTE: ' || r.p#);
    END LOOP;
END;
/

-- 11 Obtenga el nombre de proveedor para todos los proveedores que abastecen la parte P2.
CREATE OR REPLACE PROCEDURE proveedores_de_p2 IS
BEGIN
    FOR r IN (
        SELECT DISTINCT sname
        FROM S
        JOIN SP USING (s#)
        WHERE p# = 'P2'
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('PROVEEDOR: ' || r.sname);
    END LOOP;
END;
/

-- 12 Obtenga el nombre de proveedor de quienes abastecen por lo menos una parte.
CREATE OR REPLACE PROCEDURE proveedores_con_envios IS
BEGIN
    FOR r IN (
        SELECT DISTINCT sname
        FROM S
        JOIN SP USING (s#)
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('PROVEEDOR: ' || r.sname);
    END LOOP;
END;
/


-- 13 Obtenga el número de proveedor para los proveedores con estado menor que el máximo valor de estado en la tabla S.
CREATE OR REPLACE PROCEDURE proveedores_estado_menor IS
BEGIN
    FOR r IN (
        SELECT s#
        FROM S
        WHERE status < (SELECT MAX(status) FROM S)
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('PROVEEDOR: ' || r.s#);
    END LOOP;
END;
/

-- 14 Obtenga el nombre de proveedor para los proveedores que abastecen la parte P2 (aplicar EXISTS en su solución).
CREATE OR REPLACE PROCEDURE proveedores_de_p2_exists IS
BEGIN
    FOR r IN (
        SELECT sname
        FROM S s
        WHERE EXISTS (
            SELECT 1 
            FROM SP sp
            WHERE sp.s# = s.s# AND sp.p# = 'P2'
        )
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('PROVEEDOR: ' || r.sname);
    END LOOP;
END;
/

-- 15 Obtenga el nombre de proveedor para los proveedores que no abastecen la parte P2.
CREATE OR REPLACE PROCEDURE proveedores_no_p2 IS
BEGIN
    FOR r IN (
        SELECT sname
        FROM S s
        WHERE NOT EXISTS (
            SELECT 1 
            FROM SP sp
            WHERE sp.s# = s.s# AND sp.p# = 'P2'
        )
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('PROVEEDOR: ' || r.sname);
    END LOOP;
END;
/

-- 16 Obtenga el nombre de proveedor para los proveedores que abastecen todas las partes.
CREATE OR REPLACE PROCEDURE proveedores_todas_partes IS
BEGIN
    FOR r IN (
        SELECT sname
        FROM S s
        WHERE NOT EXISTS (
            SELECT p#
            FROM P p
            WHERE NOT EXISTS (
                SELECT 1 
                FROM SP sp
                WHERE sp.s# = s.s# AND sp.p# = p.p#
            )
        )
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('PROVEEDOR: ' || r.sname);
    END LOOP;
END;
/

-- 17 Obtenga el número de parte para todas las partes que pesan más de 16 libras ó son abastecidas por el proveedor S2, ó cumplen con ambos criterios.
CREATE OR REPLACE PROCEDURE partes_pesadas_o_s2 IS
BEGIN
    FOR r IN (
        SELECT DISTINCT p#
        FROM P
        WHERE weight > 16
        UNION
        SELECT DISTINCT p#
        FROM SP
        WHERE s# = 'S2'
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('PARTE: ' || r.p#);
    END LOOP;
END;
/
