DROP TABLE IF EXISTS dbo.q21_experiment_results;
GO

CREATE TABLE dbo.q21_experiment_results (
    run_id INT IDENTITY(1,1),
    test_size BIGINT,
    status VARCHAR(20),
    start_time DATETIME2,
    end_time DATETIME2,
    duration_ms BIGINT
);
GO