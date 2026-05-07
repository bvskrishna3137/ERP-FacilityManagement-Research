-- ================================================
-- ERP Facility Management Research
-- Database Schema
-- Author: Venkata Sai Krishna Baggu
-- University of North Texas
-- ================================================

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
    has_vendor_invoice VARCHAR(5),
    revenue_match VARCHAR(20),
    cost_match VARCHAR(20),
    profit_margin NUMERIC(12, 2),
    manager VARCHAR(30)
);

COMMENT ON TABLE work_orders IS 
'ERP Research - 3,930 work orders Mar 2025 to Mar 2026';
