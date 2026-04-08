PRINT '===== Q21 + P19 + P40 EXPERIMENT =====';

DECLARE @limit BIGINT = 1000;
DECLARE @start_time DATETIME2;
DECLARE @end_time DATETIME2;
DECLARE @duration BIGINT;

WHILE 1 = 1
BEGIN
    PRINT '----------------------------------------';
    PRINT 'Running for size = ' + CAST(@limit AS VARCHAR);

    -- ADMIN SECTION
    ALTER SECURITY POLICY dbo.q21_p19_p40 WITH (STATE = ON);

    DBCC FREEPROCCACHE;
    DBCC DROPCLEANBUFFERS;

    SET STATISTICS TIME ON;
    SET STATISTICS IO ON;

    SET @start_time = SYSDATETIME();

    BEGIN TRY

        -- SWITCH TO USER ONLY FOR QUERY
        EXECUTE AS USER = 'user1';

        SELECT
            s.s_name,
            COUNT(*) AS numwait
        FROM
            dbo.supplier s,
            dbo.lineitem l1,
            dbo.orders o,
            dbo.nation n
        WHERE
            s.s_suppkey = l1.l_suppkey
            AND o.o_orderkey = l1.l_orderkey
            AND o.o_orderstatus = 'F'
            AND l1.l_receiptdate > l1.l_commitdate
            AND l1.l_orderkey <= @limit

            AND EXISTS (
                SELECT 1
                FROM dbo.lineitem l2
                WHERE l2.l_orderkey = l1.l_orderkey
                  AND l2.l_suppkey <> l1.l_suppkey
            )
            AND NOT EXISTS (
                SELECT 1
                FROM dbo.lineitem l3
                WHERE l3.l_orderkey = l1.l_orderkey
                  AND l3.l_suppkey <> l1.l_suppkey
                  AND l3.l_receiptdate > l3.l_commitdate
            )
            AND s.s_nationkey = n.n_nationkey
            AND n.n_name = 'GERMANY'
        GROUP BY s.s_name
        OPTION (RECOMPILE);

        -- BACK TO ADMIN
        REVERT;

        SET @end_time = SYSDATETIME();
        SET @duration = DATEDIFF(MILLISECOND, @start_time, @end_time);

        PRINT 'SUCCESS at size = ' + CAST(@limit AS VARCHAR);

        INSERT INTO dbo.q21_experiment_results
        VALUES (@limit, 'SUCCESS', @start_time, @end_time, @duration);

    END TRY
    BEGIN CATCH

        IF USER_NAME() = 'user1'
            REVERT;

        SET @end_time = SYSDATETIME();
        SET @duration = DATEDIFF(MILLISECOND, @start_time, @end_time);

        PRINT 'FAILED at size = ' + CAST(@limit AS VARCHAR);

        INSERT INTO dbo.q21_experiment_results
        VALUES (@limit, 'FAILED', @start_time, @end_time, @duration);

        BREAK;
    END CATCH;

    SET STATISTICS TIME OFF;
    SET STATISTICS IO OFF;

    SET @limit = @limit * 2;
END
GO