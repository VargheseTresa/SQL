

USE master;
Go

-- Check query statistics to obtain information
-- about all queries on your server and resources 
-- that each of them is using
SELECT
     [DB Name]                    = COALESCE(DB_NAME(t.dbid),'Unknown')
   , [Object Type]                = ecp.objtype
   , [Adhoc Batch or Object Call] = t.[text]
   , [Executed Statement]         = SUBSTRING
      ( 
           t.[text]
         , ( qs.statement_start_offset /2 ) + 1
         , (
            (
               CASE qs.statement_end_offset
                  WHEN -1 
                     THEN DATALENGTH(t.[text]) 
                  ELSE qs.statement_end_offset
               END
               - qs.statement_start_offset
            ) /2
           ) + 1
      )
   , Counts                      = qs.execution_count
   , [Total Worker Time]         = qs.total_worker_time
   , [Avg Worker Time]           = ( qs.total_worker_time / qs.execution_count )
   , [Total Physical Reads]      = qs.total_physical_reads
   , [Avg Physical Reads]        = ( qs.total_physical_reads / qs.execution_count )
   , [Total Logical Writes]      = qs.total_logical_writes
   , [Avg Logical Writes]        = ( qs.total_logical_writes / qs.execution_count )
   , [Total Logical Reads]       = qs.total_logical_reads
   , [Avg Logical Reads]         = ( qs.total_logical_reads / qs.execution_count )
   , [Total CLR Time]            = qs.total_clr_time
   , [Avg CLR Time]              = ( qs.total_clr_time / qs.execution_count )
   , [Total Elapsed Time]        = qs.total_elapsed_time
   , [Avg Elapsed Time]          = ( qs.total_elapsed_time / qs.execution_count )
   , [Last Exec Time]            = qs.last_execution_time
   , [Creation Time]             = qs.creation_time
FROM sys.dm_exec_query_stats AS qs
    JOIN sys.dm_exec_cached_plans ecp ON qs.plan_handle = ecp.plan_handle
        CROSS APPLY sys.dm_exec_sql_text( qs.sql_handle ) AS t
-- ORDER BY [Total Worker Time] DESC
-- ORDER BY [Total Physical Reads] DESC
-- ORDER BY [Total Logical Writes] DESC
-- ORDER BY [Total Logical Reads] DESC
-- ORDER BY [Total CLR Time] DESC
-- ORDER BY [Total Elapsed Time] DESC
ORDER BY Counts DESC;


-- Quick and easy way to determine which 
-- statements aren't reusing query plans
SELECT 
     b.cacheobjtype
   , b.objtype
   , b.usecounts
   , a.dbid
   , a.objectid
   , b.size_in_bytes
   , a.[text]
FROM sys.dm_exec_cached_plans as b
   CROSS APPLY sys.dm_exec_sql_text ( b.plan_handle) AS a
ORDER BY usecounts DESC;


SELECT * FROM sys.dm_db_index_operational_stats( NULL, NULL, NULL, NULL);
   -- ...or specific object in specific database
SELECT * FROM sys.dm_db_index_operational_stats(DB_ID(N'TSQL2016'), OBJECT_ID(N'TSQL2016.Sales.Customers'), NULL, NULL);    

-- Now let's be more specific
-- Find out blocking per database object
SELECT 
     [Database]   = DB_NAME( database_id )
   , ObjectID     = iops.object_id
   , ObjectName   = 
      QUOTENAME( OBJECT_SCHEMA_NAME( iops.object_id, database_id ) ) + 
      N'.' + QUOTENAME( OBJECT_NAME( iops.object_id, database_id ) )
   , IndexID      = i.index_id
   , IndexName    = i.[name]
   , [FillFactor] = i. fill_factor
   , PartitionNo  = iops.partition_number
   , IndexType    = 
      CASE
         WHEN i.is_unique = 1
            THEN 'UNIQUE '
        ELSE ''
        END + i. type_desc
   , RowLockCount = iops. row_lock_count
   , RowLockWait  = iops.row_lock_wait_count
   , BlockedPercent = CAST( 100.0 * iops.row_lock_wait_count / ( iops.row_lock_count + 1 ) AS NUMERIC(15, 2) )
   , RowLockWaitMS = iops.row_lock_wait_in_ms
   , AvgRowLockWaitS = CAST( 1.0 * iops.row_lock_wait_in_ms / (1 + iops.row_lock_wait_count ) AS NUMERIC(15, 2) )
FROM sys.dm_db_index_operational_stats( DB_ID(), NULL, NULL, NULL) iops
   INNER JOIN sys.indexes i
    ON i.object_id = iops.object_id
        AND i.index_id = iops.index_id
        AND iops. row_lock_wait_count > 0
WHERE OBJECTPROPERTY( iops.object_id, 'IsUserTable') = 1
ORDER BY iops.row_lock_wait_count DESC;



-- Execute to analyse statistics of physical I/Os on an index or heap partition:
SELECT 
     [Database]   = DB_NAME( database_id )
   , ObjectId     = iops.object_id
   , ObjectName   = 
      QUOTENAME( OBJECT_SCHEMA_NAME( iops.object_id, database_id ) ) + 
      N'.' + QUOTENAME( OBJECT_NAME( iops.object_id, database_id ) )
   , IndexName    = i.[name]
   , IndexType    = 
      CASE
         WHEN i.is_unique = 1
            THEN 'UNIQUE '
        ELSE ''
        END + i. type_desc
   , PageLatchWaitCount = iops.page_latch_wait_count
   , PageIOLatchWaitCnt = iops.page_io_latch_wait_count
   , PageIOLatchWaitMS  = iops.page_io_latch_wait_in_ms
FROM sys.dm_db_index_operational_stats( DB_ID(), NULL, NULL, NULL ) iops
   INNER JOIN sys.indexes i
      ON i.object_id = iops.object_id
         AND i.index_id = iops.index_id
ORDER BY iops.page_latch_wait_count + iops.page_io_latch_wait_count DESC;



--stored procedure to get info about databases
sp_helpdb

-- sp that list all session related info
sp_who2

/* RUNNABLE is the current session.

