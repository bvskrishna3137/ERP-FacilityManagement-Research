-- ============================================================
-- ERP Facility Management Research Project
-- SQL Analysis Queries
-- Database: erp_research
-- Final Table: work_orders
-- Total Rows Loaded: 3,930
-- Created by: Venkata Sai Krishna Baggu
-- ============================================================


-- ============================================================
-- Query 1: Overall Financial Summary
-- ============================================================

SELECT
    COUNT(*) AS total_work_orders,
    ROUND(SUM(grand_total), 2) AS total_revenue,
    ROUND(SUM(vendor_invoice_total), 2) AS total_vendor_cost,
    ROUND(SUM(profit_margin), 2) AS total_profit,
    ROUND(AVG(profit_margin), 2) AS avg_profit_per_work_order
FROM work_orders;


-- ============================================================
-- Query 2: Financial Reconciliation Check
-- Complete rows should show difference = 0.00
-- ============================================================

SELECT
    COUNT(*) AS complete_financial_rows,
    ROUND(SUM(grand_total), 2) AS revenue_complete_rows,
    ROUND(SUM(vendor_invoice_total), 2) AS vendor_cost_complete_rows,
    ROUND(SUM(grand_total - vendor_invoice_total), 2) AS calculated_profit_complete_rows,
    ROUND(SUM(profit_margin), 2) AS imported_profit_complete_rows,
    ROUND(SUM((grand_total - vendor_invoice_total) - profit_margin), 2) AS difference
FROM work_orders
WHERE grand_total IS NOT NULL
  AND vendor_invoice_total IS NOT NULL
  AND profit_margin IS NOT NULL;


-- ============================================================
-- Query 3: Missing Financial Values by Status
-- ============================================================

SELECT
    status,
    has_vendor_invoice,
    COUNT(*) AS row_count,
    ROUND(SUM(grand_total), 2) AS revenue_amount
FROM work_orders
WHERE vendor_invoice_total IS NULL
   OR profit_margin IS NULL
   OR grand_total IS NULL
GROUP BY status, has_vendor_invoice
ORDER BY row_count DESC;


-- ============================================================
-- Query 4: Client Performance Analysis
-- ============================================================

SELECT
    client,
    COUNT(*) AS total_work_orders,
    ROUND(SUM(grand_total), 2) AS total_revenue,
    ROUND(SUM(vendor_invoice_total), 2) AS total_vendor_cost,
    ROUND(SUM(profit_margin), 2) AS total_profit,
    ROUND(AVG(profit_margin), 2) AS avg_profit_per_work_order,
    ROUND(
        SUM(profit_margin) * 100.0 / NULLIF(SUM(grand_total), 0),
        2
    ) AS profit_margin_percent
FROM work_orders
GROUP BY client
ORDER BY total_profit DESC;


-- ============================================================
-- Query 5: Top 10 Vendors by Work Order Volume
-- ============================================================

SELECT
    vendor,
    COUNT(*) AS total_work_orders,
    ROUND(SUM(grand_total), 2) AS total_revenue,
    ROUND(SUM(vendor_invoice_total), 2) AS total_vendor_cost,
    ROUND(SUM(profit_margin), 2) AS total_profit,
    ROUND(AVG(profit_margin), 2) AS avg_profit_per_work_order
FROM work_orders
GROUP BY vendor
ORDER BY total_work_orders DESC
LIMIT 10;


-- ============================================================
-- Query 6: Top 10 Categories by Profitability
-- ============================================================

SELECT
    category,
    COUNT(*) AS total_work_orders,
    ROUND(SUM(grand_total), 2) AS total_revenue,
    ROUND(SUM(vendor_invoice_total), 2) AS total_vendor_cost,
    ROUND(SUM(profit_margin), 2) AS total_profit,
    ROUND(AVG(profit_margin), 2) AS avg_profit_per_work_order,
    ROUND(
        SUM(profit_margin) * 100.0 / NULLIF(SUM(grand_total), 0),
        2
    ) AS profit_margin_percent
FROM work_orders
GROUP BY category
ORDER BY total_profit DESC
LIMIT 10;


-- ============================================================
-- Query 7: NTE Category Profitability Analysis
-- ============================================================

SELECT
    nte_category,
    COUNT(*) AS total_work_orders,
    ROUND(SUM(grand_total), 2) AS total_revenue,
    ROUND(SUM(vendor_invoice_total), 2) AS total_vendor_cost,
    ROUND(SUM(profit_margin), 2) AS total_profit,
    ROUND(AVG(profit_margin), 2) AS avg_profit_per_work_order,
    ROUND(
        SUM(profit_margin) * 100.0 / NULLIF(SUM(grand_total), 0),
        2
    ) AS profit_margin_percent
FROM work_orders
GROUP BY nte_category
ORDER BY total_profit DESC;


-- ============================================================
-- Query 8: Status Category Analysis
-- ============================================================

SELECT
    status_category,
    COUNT(*) AS total_work_orders,
    ROUND(SUM(grand_total), 2) AS total_revenue,
    ROUND(SUM(vendor_invoice_total), 2) AS total_vendor_cost,
    ROUND(SUM(profit_margin), 2) AS total_profit,
    ROUND(AVG(profit_margin), 2) AS avg_profit_per_work_order
FROM work_orders
GROUP BY status_category
ORDER BY total_work_orders DESC;


-- ============================================================
-- Query 9: Geographic Analysis by State
-- ============================================================

SELECT
    state,
    COUNT(*) AS total_work_orders,
    ROUND(SUM(grand_total), 2) AS total_revenue,
    ROUND(SUM(vendor_invoice_total), 2) AS total_vendor_cost,
    ROUND(SUM(profit_margin), 2) AS total_profit,
    ROUND(AVG(profit_margin), 2) AS avg_profit_per_work_order
FROM work_orders
GROUP BY state
ORDER BY total_work_orders DESC
LIMIT 15;


-- ============================================================
-- Query 10: Priority / Urgency Profitability Analysis
-- ============================================================

SELECT
    priority,
    COUNT(*) AS total_work_orders,
    ROUND(SUM(grand_total), 2) AS total_revenue,
    ROUND(SUM(vendor_invoice_total), 2) AS total_vendor_cost,
    ROUND(SUM(profit_margin), 2) AS total_profit,
    ROUND(AVG(profit_margin), 2) AS avg_profit_per_work_order
FROM work_orders
GROUP BY priority
ORDER BY total_work_orders DESC;


-- ============================================================
-- Query 11: Cost Match / Vendor Cost Mismatch Analysis
-- ============================================================

SELECT
    cost_match,
    COUNT(*) AS total_work_orders,
    ROUND(SUM(grand_total), 2) AS total_revenue,
    ROUND(SUM(vendor_invoice_total), 2) AS total_vendor_cost,
    ROUND(SUM(profit_margin), 2) AS total_profit,
    ROUND(AVG(profit_margin), 2) AS avg_profit_per_work_order
FROM work_orders
GROUP BY cost_match
ORDER BY total_work_orders DESC;


-- ============================================================
-- Query 12: Top Vendors with Cost Mismatches
-- ============================================================

SELECT
    vendor,
    COUNT(*) AS total_work_orders,
    COUNT(*) FILTER (WHERE cost_match = 'Different') AS cost_mismatch_count,
    COUNT(*) FILTER (WHERE cost_match = 'Match') AS cost_match_count,
    ROUND(
        COUNT(*) FILTER (WHERE cost_match = 'Different') * 100.0 / COUNT(*),
        2
    ) AS mismatch_percent,
    ROUND(SUM(profit_margin), 2) AS total_profit,
    ROUND(AVG(profit_margin), 2) AS avg_profit_per_work_order
FROM work_orders
GROUP BY vendor
HAVING COUNT(*) FILTER (WHERE cost_match = 'Different') > 0
ORDER BY cost_mismatch_count DESC, mismatch_percent DESC
LIMIT 15;


-- ============================================================
-- Query 13A: Loss-Making Work Orders Summary
-- ============================================================

SELECT
    COUNT(*) AS loss_making_work_orders,
    ROUND(SUM(profit_margin), 2) AS total_loss_amount
FROM work_orders
WHERE profit_margin < 0;


-- ============================================================
-- Query 13B: Loss-Making Work Orders by Vendor and Category
-- ============================================================

SELECT
    vendor,
    category,
    COUNT(*) AS loss_work_orders,
    ROUND(SUM(profit_margin), 2) AS total_loss_amount,
    ROUND(AVG(profit_margin), 2) AS avg_loss_per_work_order
FROM work_orders
WHERE profit_margin < 0
GROUP BY vendor, category
ORDER BY total_loss_amount ASC
LIMIT 15;


-- ============================================================
-- Query 14: Manager Profitability Analysis
-- ============================================================

SELECT
    manager,
    COUNT(*) AS total_work_orders,
    ROUND(SUM(grand_total), 2) AS total_revenue,
    ROUND(SUM(vendor_invoice_total), 2) AS total_vendor_cost,
    ROUND(SUM(profit_margin), 2) AS total_profit,
    ROUND(AVG(profit_margin), 2) AS avg_profit_per_work_order,
    ROUND(
        SUM(profit_margin) * 100.0 / NULLIF(SUM(grand_total), 0),
        2
    ) AS profit_margin_percent
FROM work_orders
GROUP BY manager
ORDER BY total_profit DESC;


-- ============================================================
-- Query 15: Status by Client Cross-Tab
-- ============================================================

SELECT
    client,
    COUNT(*) AS total_work_orders,

    COUNT(*) FILTER (WHERE status_category = '1_Completed_Paid') AS completed_paid,
    COUNT(*) FILTER (WHERE status_category = '2_Invoice_Stage') AS invoice_stage,
    COUNT(*) FILTER (WHERE status_category = '3_In_Progress') AS in_progress,
    COUNT(*) FILTER (WHERE status_category = '4_Quote_Stage') AS quote_stage,
    COUNT(*) FILTER (WHERE status_category = '5_Rejected_Cancelled') AS rejected_cancelled,

    ROUND(
        COUNT(*) FILTER (WHERE status_category = '1_Completed_Paid') * 100.0 / COUNT(*),
        2
    ) AS completion_percent
FROM work_orders
GROUP BY client
ORDER BY total_work_orders DESC;


-- ============================================================
-- Query 16: Final Data Quality Summary
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT client) AS distinct_clients,
    COUNT(DISTINCT vendor) AS distinct_vendors,
    COUNT(DISTINCT manager) AS distinct_managers,
    COUNT(DISTINCT state) AS distinct_states,
    COUNT(DISTINCT category) AS distinct_categories,
    COUNT(*) FILTER (WHERE profit_margin < 0) AS loss_making_rows,
    COUNT(*) FILTER (WHERE vendor_invoice_total IS NULL) AS missing_vendor_invoice_rows,
    COUNT(*) FILTER (WHERE profit_margin IS NULL) AS missing_profit_rows,
    ROUND(SUM(grand_total), 2) AS total_revenue,
    ROUND(SUM(vendor_invoice_total), 2) AS total_vendor_cost,
    ROUND(SUM(profit_margin), 2) AS total_profit
FROM work_orders;