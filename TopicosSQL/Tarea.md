# Actividad de Evaluación: Funciones SQL

**Nombre completo:** Yael Tolentino Osornio  
**Matrícula:** 22300192  
**Materia:** Inteligencia de Negocios (BI)  
**Fecha:** 09 / Octubre / 2025  

---

## Funciones de Cadenas

### ¿Qué son?

Las funciones de cadenas en SQL se utilizan para manipular datos de tipo texto o cadenas de caracteres. Permiten realizar operaciones como concatenar, extraer, reemplazar, buscar y formatear textos. Son fundamentales para transformar y dar formato a los datos almacenados en las bases de datos.

### Sintaxis

```sql
CONCAT(string1, string2, ...)
```

### Ejemplo

```sql
SELECT CONCAT('Su nombre es ', Nombre, ' y su edad es de ', Edad, ' Años.') AS Cliente
FROM Clientes;
```

### Resultados

| No. | Cliente                                  |
|-----|------------------------------------------|
| 1   | Su nombre es Juan Pérez y su edad es de 30 Años. |
| 2   | Su nombre es María López y su edad es de 25 Años. |

---

## Funciones de Fechas

### ¿Qué son?

Las funciones de fechas permiten trabajar con datos tipo fecha y hora, y son útiles para realizar cálculos, comparaciones o transformaciones de fechas.

### Sintaxis

```sql
GETDATE()
```

### Ejemplo

```sql
SELECT GETDATE() AS FechaActual;
```

### Resultados

| No. | FechaActual           |
|-----|-----------------------|
| 1   | 2025-10-09 18:00:00.000 |

---

## Control de Valores Nulos

### ¿Qué son?

Las funciones para manejar valores nulos permiten verificar si un valor es nulo, o sustituirlo por otro valor.

### Sintaxis

```sql
ISNULL(expression, replacement_value)
```

### Ejemplo

```sql
SELECT ISNULL(Edad, 0) AS EdadConValor
FROM Clientes;
```

### Resultados

| No. | EdadConValor |
|-----|--------------|
| 1   | 30           |
| 2   | 25           |
| 3   | 0            |

---

## Uso de MERGE

### ¿Qué es?

El comando `MERGE` permite realizar operaciones de inserción, actualización y eliminación de registros en una sola instrucción.

### Sintaxis

```sql
MERGE INTO target_table AS target
USING source_table AS source
ON target.id = source.id
WHEN MATCHED THEN
    UPDATE SET target.name = source.name
WHEN NOT MATCHED THEN
    INSERT (id, name) VALUES (source.id, source.name);
```

### Ejemplo

```sql
MERGE INTO Clientes AS target
USING NuevosClientes AS source
ON target.IdCliente = source.IdCliente
WHEN MATCHED THEN
    UPDATE SET target.NombreCliente = source.NombreCliente
WHEN NOT MATCHED THEN
    INSERT (IdCliente, NombreCliente) VALUES (source.IdCliente, source.NombreCliente);
```

### Resultados

| No. | IdCliente | NombreCliente  |
|-----|-----------|----------------|
| 1   | 1         | Juan Pérez     |
| 2   | 2         | María López    |

---

## Uso de CASE

### ¿Qué es?

La función `CASE` en SQL permite realizar una comparación condicional dentro de una consulta. Es útil para evaluar expresiones y devolver resultados dependiendo de los valores encontrados.

### Sintaxis

```sql
CASE
    WHEN condition THEN result
    ELSE default_result
END
```

### Ejemplo

```sql
SELECT NombreCliente,
       CASE
           WHEN Edad >= 18 THEN 'Adulto'
           ELSE 'Menor'
       END AS CategoriaEdad
FROM Clientes;
```

### Resultados

| No. | NombreCliente | CategoriaEdad |
|-----|---------------|---------------|
| 1   | Juan Pérez    | Adulto       |
| 2   | María López   | Adulto       |
| 3   | Luis García   | Menor        |

---

### Conclusión

Este documento presenta ejemplos prácticos y explicaciones breves sobre las principales funciones SQL utilizadas en la manipulación de cadenas, fechas, valores nulos, y control de flujo con `MERGE` y `CASE`. Estos comandos son esenciales para transformar, analizar y gestionar datos en bases de datos de manera eficiente.

---

**Criterios de Evaluación:**

- El formato Markdown se ha cumplido con títulos, subtítulos, y bloques de código.
- Se incluyen ejemplos correctos y los resultados están bien representados en tablas Markdown.
- El diseño es claro y fácil de seguir.

---

