-- ================================================
-- ERP Facility Management Research
-- Research SQL Queries
-- Author: Venkata Sai Krishna Baggu
-- University of North Texas
-- ================================================

-- Query 1: Work Order Distribution by Client and Status
SELECT 
    client,
    status_category,
    COUNT(*) as work_order_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY client), 2) as pct_of_client
FROM work_orders
GROUP BY client, status_category
ORDER BY client, status_category;

-- Query 2: Financial Performance Summary
SELECT 
    COUNT(*) as total_work_orders,
    ROUND(SUM(grand_total)::numeric, 2) as total_revenue,
    ROUND(SUM(vendor_invoice_total)::numeric, 2) as total_vendor_cost,
    ROUND(SUM(profit_margin)::numeric, 2) as total_profit,
    ROUND(AVG(profit_margin)::numeric, 2) as avg_profit_per_wo,
    ROUND((SUM(profit_margin) / SUM(grand_total) * 100)::numeric, 2) as profit_margin_pct
FROM work_orders
WHERE profit_margin IS NOT NULL;

-- Query 3: Client Level Profit Analysis
SELECT 
    client,
    COUNT(*) as work_orders,
    ROUND(SUM(grand_total)::numeric, 2) as revenue,
    ROUND(SUM(profit_margin)::numeric, 2) as profit,
    ROUND(AVG(profit_margin)::numeric, 2) as avg_profit_per_wo
FROM work_orders
WHERE profit_margin IS NOT NULL
GROUP BY client
ORDER BY profit DESC;

-- Query 4: NTE Threshold Analysis
SELECT 
    nte_category,
    COUNT(*) as work_orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as pct_of_total,
    ROUND(SUM(grand_total)::numeric, 2) as revenue,
    ROUND(SUM(profit_margin)::numeric, 2) as profit,
    ROUND(AVG(profit_margin)::numeric, 2) as avg_profit_per_wo
FROM work_orders
WHERE profit_margin IS NOT NULL
GROUP BY nte_category
ORDER BY avg_profit_per_wo DESC;

-- Query 5: Top 10 Vendors by Volume
SELECT 
    vendor,
    COUNT(*) as work_orders,
    ROUND(SUM(profit_margin)::numeric, 2) as total_profit,
    ROUND(AVG(profit_margin)::numeric, 2) as avg_profit_per_wo
FROM work_orders
WHERE profit_margin IS NOT NULL
GROUP BY vendor
ORDER BY work_orders DESC
LIMIT 10;

-- Query 6: Geographic Analysis by State
SELECT 
    state,
    COUNT(*) as work_orders,
    ROUND(SUM(grand_total)::numeric, 2) as revenue,
    ROUND(SUM(profit_margin)::numeric, 2) as profit,
    ROUND(AVG(profit_margin)::numeric, 2) as avg_profit_per_wo
FROM work_orders
WHERE profit_margin IS NOT NULL
GROUP BY state
ORDER BY work_orders DESC;

-- Query 7: Priority Level Analysis
SELECT 
    priority,
    COUNT(*) as work_orders,
    ROUND(SUM(profit_margin)::numeric, 2) as total_profit,
    ROUND(AVG(profit_margin)::numeric, 2) as avg_profit_per_wo
FROM work_orders
WHERE profit_margin IS NOT NULL
GROUP BY priority
ORDER BY work_orders DESC;

-- Query 8: Loss Making Jobs Analysis
SELECT 
    vendor,
    category,
    COUNT(*) as loss_jobs,
    ROUND(SUM(profit_margin)::numeric, 2) as total_loss
FROM work_orders
WHERE profit_margin < 0
GROUP BY vendor, category
ORDER BY total_loss ASC;

-- Query 9: Vendor Cost Compliance Analysis
SELECT 
    vendor,
    COUNT(*) as total_jobs,
    SUM(CASE WHEN cost_match = 'Different' THEN 1 ELSE 0 END) as overrun_count,
    ROUND(SUM(CASE WHEN cost_match = 'Different' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as overrun_rate
FROM work_orders
GROUP BY vendor
HAVING SUM(CASE WHEN cost_match = 'Different' THEN 1 ELSE 0 END) > 0
ORDER BY overrun_count DESC
LIMIT 10;

-- Query 10: Manager Performance Analysis
SELECT 
    manager,
    COUNT(*) as work_orders,
    ROUND(SUM(profit_margin)::numeric, 2) as total_profit,
    ROUND(AVG(profit_margin)::numeric, 2) as avg_profit_per_wo
FROM work_orders
WHERE profit_margin IS NOT NULL
GROUP BY manager
ORDER BY total_profit DESC;
