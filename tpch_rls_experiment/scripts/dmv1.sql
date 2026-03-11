SELECT 
  r.session_id AS SPID,
  DB_NAME(r.database_id) AS DatabaseName,
  s.login_name AS UserName,
  r.status, -- e.g., 'running', 'suspended'
  r.command, -- e.g., 'SELECT', 'BACKUP'
  r.wait_type, -- Why is it slow? (e.g., 'PAGEIOLATCH_IX' = I/O wait)
  r.wait_time / 1000 AS WaitTime_ms, -- Time spent waiting (ms)
  r.total_elapsed_time / 1000 AS TotalDuration_ms, -- Total run time (ms)
  SUBSTRING(qt.text, (r.statement_start_offset/2)+1, 
    ((CASE r.statement_end_offset 
      WHEN -1 THEN DATALENGTH(qt.text) 
      ELSE r.statement_end_offset 
     END - r.statement_start_offset)/2)+1) AS ActiveQueryText, -- Current query snippet
  qt.text AS FullQueryText -- Entire query text
FROM 
  sys.dm_exec_requests r
JOIN 
  sys.dm_exec_sessions s ON r.session_id = s.session_id
CROSS APPLY 
  sys.dm_exec_sql_text(r.sql_handle) qt
WHERE 
  r.status = 'running' -- Focus on actively executing queries
ORDER BY 
  r.total_elapsed_time DESC; -- Slowest first