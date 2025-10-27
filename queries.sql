
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



-- =====================================================

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
