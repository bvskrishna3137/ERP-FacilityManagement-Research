-- ============================================================
-- ERP Facility Management Research Project
-- PostgreSQL Schema Setup
-- Database: erp_research
-- Final Table: work_orders
-- Stage Table: work_orders_stage
-- Backup Table: work_orders_stage_backup
-- Issue Table: data_quality_numeric_issues
-- Created by: Venkata Sai Krishna Baggu
-- ============================================================


-- ============================================================
-- 1. Final Clean Table
-- ============================================================

DROP TABLE IF EXISTS work_orders;

CREATE TABLE work_orders (
    wo_number VARCHAR(50) PRIMARY KEY,
    client VARCHAR(20),
    status VARCHAR(100),
    status_category VARCHAR(50),
    state VARCHAR(10),
    category VARCHAR(100),
    order_type VARCHAR(100),
    priority VARCHAR(100),
    dne NUMERIC(12, 2),
    vendor_nte NUMERIC(12, 2),
    grand_total NUMERIC(12, 2),
    labor_amt NUMERIC(12, 2),
    material_amt NUMERIC(12, 2),
    vendor_invoice_total NUMERIC(12, 2),
    vendor_code VARCHAR(20),
    vendor VARCHAR(20),
    nte_category VARCHAR(20),
    invoice_date DATE,
    has_vendor_invoice VARCHAR(10),
    revenue_match VARCHAR(30),
    cost_match VARCHAR(30),
    profit_margin NUMERIC(12, 2),
    manager VARCHAR(30)
);

COMMENT ON TABLE work_orders IS 'ERP Research - cleaned work order dataset, 3,930 records';


-- ============================================================
-- 2. Staging Table
-- All fields are TEXT to safely import CSV before conversion
-- ============================================================

DROP TABLE IF EXISTS work_orders_stage;

CREATE TABLE work_orders_stage (
    wo_number TEXT,
    client TEXT,
    status TEXT,
    status_category TEXT,
    state TEXT,
    category TEXT,
    order_type TEXT,
    priority TEXT,
    dne TEXT,
    vendor_nte TEXT,
    grand_total TEXT,
    labor_amt TEXT,
    material_amt TEXT,
    vendor_invoice_total TEXT,
    vendor_code TEXT,
    vendor TEXT,
    nte_category TEXT,
    invoice_date TEXT,
    has_vendor_invoice TEXT,
    revenue_match TEXT,
    cost_match TEXT,
    profit_margin TEXT,
    manager TEXT
);


-- ============================================================
-- 3. Backup Staging Table
-- Run this after importing CSV into work_orders_stage
-- ============================================================

DROP TABLE IF EXISTS work_orders_stage_backup;

CREATE TABLE work_orders_stage_backup AS
SELECT *
FROM work_orders_stage;


-- ============================================================
-- 4. Data Quality Issue Table
-- Stores rows with corrupted numeric values before conversion
-- ============================================================

DROP TABLE IF EXISTS data_quality_numeric_issues;

CREATE TABLE data_quality_numeric_issues AS
SELECT
    ctid::text AS row_location,
    wo_number,
    client,
    status,
    state,
    category,
    order_type,
    priority,
    dne,
    vendor_nte,
    grand_total,
    labor_amt,
    material_amt,
    vendor_invoice_total,
    profit_margin,
    manager
FROM work_orders_stage
WHERE 
    (dne IS NOT NULL AND TRIM(dne) <> '' AND TRIM(dne) !~ '^-?[0-9]+(\.[0-9]+)?$')
 OR (grand_total IS NOT NULL AND TRIM(grand_total) <> '' AND TRIM(grand_total) !~ '^-?[0-9]+(\.[0-9]+)?$')
 OR (labor_amt IS NOT NULL AND TRIM(labor_amt) <> '' AND TRIM(labor_amt) !~ '^-?[0-9]+(\.[0-9]+)?$')
 OR (material_amt IS NOT NULL AND TRIM(material_amt) <> '' AND TRIM(material_amt) !~ '^-?[0-9]+(\.[0-9]+)?$');


-- ============================================================
-- 5. Delete Fully Blank Staging Rows
-- Removes phantom blank Excel rows after CSV import
-- ============================================================

DELETE FROM work_orders_stage
WHERE wo_number IS NULL
  AND client IS NULL
  AND status IS NULL
  AND status_category IS NULL
  AND state IS NULL
  AND category IS NULL
  AND order_type IS NULL
  AND priority IS NULL
  AND dne IS NULL
  AND vendor_nte IS NULL
  AND grand_total IS NULL
  AND labor_amt IS NULL
  AND material_amt IS NULL
  AND vendor_invoice_total IS NULL
  AND vendor_code IS NULL
  AND vendor IS NULL
  AND nte_category IS NULL
  AND invoice_date IS NULL
  AND has_vendor_invoice IS NULL
  AND revenue_match IS NULL
  AND cost_match IS NULL
  AND profit_margin IS NULL
  AND manager IS NULL;


-- ============================================================
-- 6. Insert Cleaned Data Into Final Table
-- Converts valid numeric/date values and keeps bad numeric cells as NULL
-- ============================================================

TRUNCATE TABLE work_orders;

INSERT INTO work_orders (
    wo_number,
    client,
    status,
    status_category,
    state,
    category,
    order_type,
    priority,
    dne,
    vendor_nte,
    grand_total,
    labor_amt,
    material_amt,
    vendor_invoice_total,
    vendor_code,
    vendor,
    nte_category,
    invoice_date,
    has_vendor_invoice,
    revenue_match,
    cost_match,
    profit_margin,
    manager
)
SELECT
    TRIM(wo_number),
    TRIM(client),
    TRIM(status),
    TRIM(status_category),
    TRIM(state),
    TRIM(category),
    TRIM(order_type),
    TRIM(priority),

    CASE WHEN TRIM(dne) ~ '^-?[0-9]+(\.[0-9]+)?$'
         THEN TRIM(dne)::NUMERIC(12,2) ELSE NULL END,

    CASE WHEN TRIM(vendor_nte) ~ '^-?[0-9]+(\.[0-9]+)?$'
         THEN TRIM(vendor_nte)::NUMERIC(12,2) ELSE NULL END,

    CASE WHEN TRIM(grand_total) ~ '^-?[0-9]+(\.[0-9]+)?$'
         THEN TRIM(grand_total)::NUMERIC(12,2) ELSE NULL END,

    CASE WHEN TRIM(labor_amt) ~ '^-?[0-9]+(\.[0-9]+)?$'
         THEN TRIM(labor_amt)::NUMERIC(12,2) ELSE NULL END,

    CASE WHEN TRIM(material_amt) ~ '^-?[0-9]+(\.[0-9]+)?$'
         THEN TRIM(material_amt)::NUMERIC(12,2) ELSE NULL END,

    CASE WHEN TRIM(vendor_invoice_total) ~ '^-?[0-9]+(\.[0-9]+)?$'
         THEN TRIM(vendor_invoice_total)::NUMERIC(12,2) ELSE NULL END,

    TRIM(vendor_code),
    TRIM(vendor),
    TRIM(nte_category),

    CASE 
        WHEN invoice_date IS NULL OR TRIM(invoice_date) = '' THEN NULL
        WHEN TRIM(invoice_date) ~ '^\d{4}-\d{2}-\d{2}$' THEN TRIM(invoice_date)::DATE
        WHEN TRIM(invoice_date) ~ '^\d{1,2}/\d{1,2}/\d{4}$' THEN TO_DATE(TRIM(invoice_date), 'MM/DD/YYYY')
        ELSE NULL
    END,

    TRIM(has_vendor_invoice),
    TRIM(revenue_match),
    TRIM(cost_match),

    CASE WHEN TRIM(profit_margin) ~ '^-?[0-9]+(\.[0-9]+)?$'
         THEN TRIM(profit_margin)::NUMERIC(12,2) ELSE NULL END,

    TRIM(manager)
FROM work_orders_stage
WHERE wo_number IS NOT NULL
  AND TRIM(wo_number) <> '';


-- ============================================================
-- 7. Final Row Count Check
-- Expected result: 3,930
-- ============================================================

SELECT COUNT(*) AS final_rows
FROM work_orders;