--to run ALL queries as single-threaded:
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

EXEC sp_configure 'max degree of parallelism';

EXEC sp_configure 'max degree of parallelism', 1;
RECONFIGURE;




