/*-------------------------------------------------------------------
-- 1 - Baseline
-- 
-- Summary: 
--
-- Written By: Andy Yun
-------------------------------------------------------------------*/


-----
-- Summary database size check
SELECT
	--@@SERVERNAME,
    DB_NAME(database_id) as [Database Name],
    type_desc,
	SUM(size) * 8.0 / 1024 / 1024 as 'Size (GB)'	
FROM sys.master_files
WHERE DB_NAME(database_id) IN (
	'Sandbox_MultiFile_SingleVol',
	'Sandbox_MultiFile_MultiVol'
)
GROUP BY database_id, type_desc
ORDER BY DB_NAME(database_id) DESC, type_desc DESC;
GO


-----
-- Detailed database file size check
SELECT
	--@@SERVERNAME, 
    DB_NAME(database_id) as [Database Name],
	physical_name,
	type_desc,
    size * 8.0 / 1024 / 1024 as 'Size (GB)'
FROM sys.master_files
WHERE DB_NAME(database_id) IN (
	'Sandbox_MultiFile_SingleVol',
	'Sandbox_MultiFile_MultiVol'
)
ORDER BY DB_NAME(database_id) DESC, type_desc DESC, physical_name;
GO








-----
-- Let's baseline
-- use DISK = NUL
BACKUP DATABASE Sandbox_MultiFile_SingleVol TO
DISK='NUL'
WITH COPY_ONLY, FORMAT, INIT,
	STATS = 15
GO 

BACKUP DATABASE Sandbox_MultiFile_MultiVol TO
DISK='NUL'
WITH COPY_ONLY, FORMAT, INIT,
	STATS = 15
GO 


/*
-- Note the differences
-- Record best case scenario here:
SingleVol:
BACKUP DATABASE successfully processed xxx pages in xxx seconds (xxx MB/sec).

MultiVol:
BACKUP DATABASE successfully processed xxx pages in xxx seconds (xxx MB/sec).
*/








-----
-- Will any of our tuneables help
-- DISK = NUL?
BACKUP DATABASE Sandbox_MultiFile_SingleVol TO
	DISK='NUL', DISK='NUL', DISK='NUL', DISK='NUL'
WITH COPY_ONLY, FORMAT, INIT,
	STATS = 15
GO 

BACKUP DATABASE Sandbox_MultiFile_MultiVol TO
	DISK='NUL', DISK='NUL', DISK='NUL', DISK='NUL'
WITH COPY_ONLY, FORMAT, INIT,
	STATS = 15
GO 








-----
-- Let's change BUFFERCOUNT
BACKUP DATABASE Sandbox_MultiFile_SingleVol TO
	DISK='NUL'
WITH COPY_ONLY, FORMAT, INIT,
	BUFFERCOUNT = 50,
	STATS = 15
GO 

BACKUP DATABASE Sandbox_MultiFile_MultiVol TO
	DISK='NUL'
WITH COPY_ONLY, FORMAT, INIT,
	BUFFERCOUNT = 50,
	STATS = 15
GO 








-----
-- How do we even know what tuneable settings are being used in the first place?
--
-- Trace Flag 3213 - Generate diagnostic data about BACKUP & RESTORE operation (least)
-- Trace Flag 3004 - Generate diagnostic data about BACKUP & RESTORE operation (more)
-- Trace Flag 3014 - Generate diagnostic data about BACKUP & RESTORE operation (all)
-- Undocumented
-- 
-- Trace Flag 3604 - Redirects output information to SSMS Results Pane
-- Trace Flag 3605 - Redirects output information to SQL Server Error Log: use if you need timestamps


-----
-- Turn on Trace Flags
DBCC TRACEON(3604, 3004, 3014, 3213, -1);
GO

PRINT '--------------'
PRINT '--------------'
BACKUP DATABASE Sandbox_MultiFile_SingleVol TO
	DISK='NUL'
WITH COPY_ONLY, FORMAT, INIT,
	STATS = 15
GO 

PRINT '--------------'
PRINT '--------------'
BACKUP DATABASE Sandbox_MultiFile_MultiVol TO
	DISK='NUL'
WITH COPY_ONLY, FORMAT, INIT,
	STATS = 15
GO 


-- Review output
-- Note: 
-- Total buffer space
-- Number of data file readers
--
-- Does Default BufferCount line up?
/*
Default BufferCount = (
	Num_of_Backup_Devices * (
			1 + Suggested_IO_Depth
		) 
	) + Num_of_Backup_Devices + (
		2 * Database_Device_Count
	)

Num_of_Backup_Devices = # of bak files
Suggested_IO_Depth = 3 when DISK
Database_Device_Count = # of DB volumes
*/


