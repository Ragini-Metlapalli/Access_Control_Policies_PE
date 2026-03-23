DECLARE @sql NVARCHAR(MAX) = '';

SELECT @sql += 
    'DROP INDEX [' + i.name + '] ON [' + s.name + '].[' + t.name + '];' + CHAR(10)
FROM sys.indexes i
JOIN sys.tables t ON i.object_id = t.object_id
JOIN sys.schemas s ON t.schema_id = s.schema_id
LEFT JOIN sys.key_constraints kc 
    ON i.object_id = kc.parent_object_id 
    AND i.index_id = kc.unique_index_id
WHERE 
    i.type_desc <> 'HEAP'
    AND kc.type IS NULL
    AND i.is_primary_key = 0
    AND i.is_unique_constraint = 0;

PRINT @sql;
EXEC sp_executesql @sql;