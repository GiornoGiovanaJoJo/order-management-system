-- =====================================================
-- SQL QUERIES FOR ORDER MANAGEMENT SYSTEM
-- Task 2: Required SQL Queries
-- =====================================================

-- =====================================================
-- QUERY 2.1
-- Get the sum of goods ordered by each customer
-- Result: Customer Name and Total Order Amount
-- =====================================================

SELECT
    c.name AS client_name,
    COALESCE(SUM(oi.price * oi.quantity), 0) AS total_ordered_amount
FROM
    clients c
LEFT JOIN
    orders o ON c.id = o.client_id
LEFT JOIN
    order_items oi ON o.id = oi.order_id
GROUP BY
    c.id, c.name
ORDER BY
    total_ordered_amount DESC;

/*
EXPLANATION:
- LEFT JOIN clients with orders: includes clients even without orders
- LEFT JOIN orders with order_items: includes orders even without items
- SUM(oi.price * oi.quantity): calculates total sum per client
- COALESCE(..., 0): replaces NULL with 0 for clients without orders
- GROUP BY: aggregates data per client
- ORDER BY: sorts by total amount in descending order

EXPECTED OUTPUT EXAMPLE:
client_name          | total_ordered_amount
---------------------|---------------------
ООО "Ромашка"        | 394000.00
ЗАО "Инвестпром"     | 303000.00
ООО "Торгсервис"     | 220000.00
ИП Петров            | 194000.00
*/

-- =====================================================
-- QUERY 2.2
-- Find the count of first-level child categories for each category
-- Result: Category Name and Count of Direct Children
-- =====================================================

SELECT
    parent.name AS category_name,
    COUNT(child.id) AS first_level_children_count
FROM
    categories parent
LEFT JOIN
    categories child ON parent.id = child.parent_id
GROUP BY
    parent.id, parent.name
ORDER BY
    parent.id;

/*
EXPLANATION:
- Self-join categories: parent table and child table
- parent.id = child.parent_id: defines parent-child relationship
- LEFT JOIN: includes categories without children (count = 0)
- COUNT(child.id): counts direct children (first level only)
- GROUP BY: aggregates per category
- ORDER BY: sorts by category ID for logical hierarchy display

HIERARCHICAL TREE EXAMPLE:
Бытовая техника (3 children: Стиральные машины, Холодильники, Телевизоры)
    Стиральные машины (0 children)
    Холодильники (2 children: однокамерные, двухкамерные)
        однокамерные (0 children)
        двухкамерные (0 children)
    Телевизоры (0 children)
Компьютеры (2 children: Ноутбуки, Моноблоки)
    Ноутбуки (2 children: 17", 19")
        17" (0 children)
        19" (0 children)
    Моноблоки (0 children)

EXPECTED OUTPUT:
category_name        | first_level_children_count
---------------------|----------------------------
Бытовая техника      | 3
Стиральные машины    | 0
Холодильники         | 2
однокамерные         | 0
двухкамерные         | 0
Телевизоры           | 0
Компьютеры           | 2
Ноутбуки             | 2
17"                  | 0
19"                  | 0
Моноблоки            | 0
*/

-- =====================================================
-- BONUS QUERIES
-- =====================================================

-- BONUS: Get all categories with their full hierarchical path
-- Useful for breadcrumb navigation
WITH RECURSIVE category_path AS (
    SELECT 
        id, 
        name, 
        parent_id, 
        name as full_path,
        1 as depth
    FROM categories
    WHERE parent_id IS NULL
    
    UNION ALL
    
    SELECT 
        c.id, 
        c.name, 
        c.parent_id,
        CONCAT(cp.full_path, ' > ', c.name),
        cp.depth + 1
    FROM categories c
    INNER JOIN category_path cp ON c.parent_id = cp.id
)
SELECT 
    id,
    name,
    full_path as hierarchical_path,
    depth as nesting_level
FROM category_path
ORDER BY full_path;

-- BONUS: Get product count in each category (including nested products)
-- Shows total products for a category and all its subcategories
WITH RECURSIVE category_tree AS (
    SELECT id, parent_id FROM categories
    
    UNION ALL
    
    SELECT c.id, ct.parent_id
    FROM categories c
    INNER JOIN category_tree ct ON c.parent_id = ct.id
)
SELECT 
    c.name as category_name,
    COUNT(DISTINCT p.id) as product_count
FROM categories c
LEFT JOIN category_tree ct ON c.id = ct.id
LEFT JOIN products p ON ct.id = p.category_id
GROUP BY c.id, c.name
ORDER BY c.id;

-- =====================================================
-- END OF QUERIES
-- =====================================================
