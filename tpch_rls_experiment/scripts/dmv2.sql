SELECT 
  wt.blocking_session_id AS BlockingSPID,
  wt.session_id AS BlockedSPID,
  wt.wait_type,
  wt.wait_duration_ms / 1000 AS WaitDuration_ms,
  qt.text AS BlockedQuery
FROM 
  sys.dm_os_waiting_tasks wt
JOIN 
  sys.dm_exec_requests r 
    ON wt.session_id = r.session_id
CROSS APPLY 
  sys.dm_exec_sql_text(r.sql_handle) qt
WHERE 
  wt.blocking_session_id <> 0;