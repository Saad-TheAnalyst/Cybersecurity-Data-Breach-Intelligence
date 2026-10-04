/*
Cybersecurity & Data Breach Intelligence System
Database: cybersecurity_db
Table: data_breaches
Generated: 2026
*/

CREATE DATABASE IF NOT EXISTS cybersecurity_db;
USE cybersecurity_db;

-- 1. Table Schema
CREATE TABLE IF NOT EXISTS data_breaches (
    id INT AUTO_INCREMENT PRIMARY KEY,
    organisation VARCHAR(255) NOT NULL,
    year INT NOT NULL,
    records_lost BIGINT NOT NULL,
    sector VARCHAR(100),
    method VARCHAR(255),
    severity VARCHAR(50),
    decade VARCHAR(20),
    log_records DOUBLE,
    is_recent INT,
    is_major_tech INT,
    attack_category VARCHAR(100)
);

-- Query 1: Total records lost and breach count by sector

    -- Query 1: Total records lost and breach count by sector using GROUP BY ORDER BY
    SELECT 
        sector,
        COUNT(*) AS breach_count,
        SUM(records_lost) AS total_records_lost,
        ROUND(AVG(records_lost), 0) AS avg_records_lost
    FROM data_breaches
    GROUP BY sector
    ORDER BY total_records_lost DESC;
    

-- Query 2: Most dangerous attack methods by average records lost

    -- Query 2: Most dangerous attack methods by average records lost using GROUP BY HAVING
    SELECT 
        attack_category,
        COUNT(*) AS incident_count,
        ROUND(AVG(records_lost), 0) AS avg_records_lost,
        MAX(records_lost) AS max_records_lost
    FROM data_breaches
    GROUP BY attack_category
    HAVING COUNT(*) >= 5
    ORDER BY avg_records_lost DESC;
    

-- Query 3: Breach severity classification by decade

    -- Query 3: Breach severity classification by decade using CASE WHEN and GROUP BY
    SELECT 
        decade,
        COUNT(*) AS total_breaches,
        SUM(CASE WHEN severity = 'Critical' THEN 1 ELSE 0 END) AS critical_count,
        SUM(CASE WHEN severity = 'High' THEN 1 ELSE 0 END) AS high_count,
        SUM(CASE WHEN severity = 'Medium' THEN 1 ELSE 0 END) AS medium_count,
        SUM(CASE WHEN severity = 'Low' THEN 1 ELSE 0 END) AS low_count,
        ROUND(100.0 * SUM(CASE WHEN severity = 'Critical' THEN 1 ELSE 0 END) / COUNT(*), 2) AS critical_pct
    FROM data_breaches
    GROUP BY decade
    ORDER BY decade ASC;
    

-- Query 4: Year over year breach growth using Window Functions LAG()

    -- Query 4: Year over year breach growth using Window Functions LAG()
    WITH yearly_stats AS (
        SELECT 
            year,
            COUNT(*) AS breach_count,
            SUM(records_lost) AS total_records
        FROM data_breaches
        GROUP BY year
    )
    SELECT 
        year,
        breach_count,
        LAG(breach_count, 1) OVER (ORDER BY year) AS prev_year_breaches,
        breach_count - LAG(breach_count, 1) OVER (ORDER BY year) AS yoy_breach_change,
        ROUND(100.0 * (breach_count - LAG(breach_count, 1) OVER (ORDER BY year)) / NULLIF(LAG(breach_count, 1) OVER (ORDER BY year), 0), 2) AS yoy_breach_growth_pct,
        total_records
    FROM yearly_stats
    ORDER BY year ASC;
    

-- Query 5: Top 10 most breached organisations using CTE and ORDER BY LIMIT

    -- Query 5: Top 10 most breached organisations using CTE and ORDER BY LIMIT
    WITH org_breach_summary AS (
        SELECT 
            organisation,
            sector,
            COUNT(*) AS total_breaches,
            SUM(records_lost) AS total_records_compromised,
            MAX(records_lost) AS single_largest_breach
        FROM data_breaches
        GROUP BY organisation, sector
    )
    SELECT 
        organisation,
        sector,
        total_breaches,
        total_records_compromised,
        single_largest_breach,
        DENSE_RANK() OVER (ORDER BY total_records_compromised DESC) AS breach_rank
    FROM org_breach_summary
    ORDER BY total_records_compromised DESC
    LIMIT 10;
    
