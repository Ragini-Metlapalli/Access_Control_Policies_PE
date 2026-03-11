SELECT 
    r.session_id,
    r.blocking_session_id,
    r.status,
    r.command,
    DB_NAME(r.database_id) AS database_name,
    qt.text AS sql_text
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) qt
WHERE r.session_id > 50;