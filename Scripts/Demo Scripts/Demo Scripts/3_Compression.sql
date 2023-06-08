/*-------------------------------------------------------------------
-- 3 - Compression
-- 
-- Summary: 
--
-- Written By: Andy Yun
-------------------------------------------------------------------*/
-----
-- Check current state of QAT
SELECT * 
FROM sys.dm_server_accelerator_status;
GO

/*
-- Software Mode - must restart SQL Services
ALTER SERVER CONFIGURATION
SET HARDWARE_OFFLOAD = ON (ACCELERATOR = QAT, MODE = SOFTWARE)
GO
*/








/*
Quick Syntax Reference:

NO_COMPRESSION,
COMPRESSION (ALGORITHM = QAT_DEFLATE),
COMPRESSION (ALGORITHM = MS_XPRESS),	-- Default compression
*/








-----
-- Compare & contrast compression algorithms
-- Baseline
DBCC TRACEON(3604, 3213, -1);
GO

PRINT '---'
BACKUP DATABASE Sandbox_MultiFile_SingleVol TO
	DISK = N'\\10.21.200.27\ayun-sql-backups\Sandbox_MultiFile_SingleVol_1.bak'
WITH COPY_ONLY, FORMAT, INIT,
	COMPRESSION (ALGORITHM = MS_XPRESS),	-- Default compression
	STATS = 15
GO 

GO
PRINT '---'
BACKUP DATABASE Sandbox_MultiFile_SingleVol TO
	DISK = N'\\10.21.200.27\ayun-sql-backups\Sandbox_MultiFile_SingleVol_1.bak'
WITH COPY_ONLY, FORMAT, INIT,
	COMPRESSION (ALGORITHM = QAT_DEFLATE),
	STATS = 15
GO 


-- Note Buffer Sets








------
-- Let's look at the output backup file sizes
SELECT DISTINCT 
	backupset.database_name,
	backupset.Backup_Start_Date,
	DATEDIFF(ms, backupset.backup_start_date, backupset.backup_finish_date) AS ms_taken,
	CONVERT(decimal(10, 2), backupset.backup_size/1024./1024.) AS backup_size_mb,
	CONVERT(decimal(10, 2), backupset.compressed_backup_size/1024./1024.) AS comp_backup_size_mb,
	backupset.compression_algorithm
	--bs.flags, bs.description, bms.description, bs.name, bms.name
FROM msdb.dbo.backupset
WHERE backupset.backup_start_date > DATEADD(HOUR, -1, sysdatetime()) --only look at last 1 hour
ORDER BY backupset.Backup_Start_Date DESC
GO








-----
-- How are tunables impacted?
DBCC TRACEOFF(3604, 3004, 3014, 3213, -1);
GO
PRINT '--- COMPRESSION = MS_XPRESS ---'
BACKUP DATABASE Sandbox_MultiFile_SingleVol TO
	DISK = N'\\10.21.200.27\ayun-sql-backups\Sandbox_MultiFile_SingleVol_1.bak',
	DISK = N'\\10.21.200.28\ayun-sql-backups\Sandbox_MultiFile_SingleVol_2.bak',
	DISK = N'\\10.21.200.70\ayun-sql-backups\Sandbox_MultiFile_SingleVol_3.bak',
	DISK = N'\\10.21.200.71\ayun-sql-backups\Sandbox_MultiFile_SingleVol_4.bak',
	DISK = N'\\10.21.200.72\ayun-sql-backups\Sandbox_MultiFile_SingleVol_5.bak',
	DISK = N'\\10.21.200.73\ayun-sql-backups\Sandbox_MultiFile_SingleVol_6.bak',
	DISK = N'\\10.21.200.74\ayun-sql-backups\Sandbox_MultiFile_SingleVol_7.bak',
	DISK = N'\\10.21.200.75\ayun-sql-backups\Sandbox_MultiFile_SingleVol_8.bak'
WITH COPY_ONLY, FORMAT, INIT,
	COMPRESSION (ALGORITHM = MS_XPRESS),	-- Default compression
	BUFFERCOUNT = 100,
	MAXTRANSFERSIZE = 4194304,
	STATS = 15
GO 

PRINT ''
PRINT '--- COMPRESSION = QAT_DEFLATE ---'
BACKUP DATABASE Sandbox_MultiFile_SingleVol TO
	DISK = N'\\10.21.200.27\ayun-sql-backups\Sandbox_MultiFile_SingleVol_1.bak',
	DISK = N'\\10.21.200.28\ayun-sql-backups\Sandbox_MultiFile_SingleVol_2.bak',
	DISK = N'\\10.21.200.70\ayun-sql-backups\Sandbox_MultiFile_SingleVol_3.bak',
	DISK = N'\\10.21.200.71\ayun-sql-backups\Sandbox_MultiFile_SingleVol_4.bak',
	DISK = N'\\10.21.200.72\ayun-sql-backups\Sandbox_MultiFile_SingleVol_5.bak',
	DISK = N'\\10.21.200.73\ayun-sql-backups\Sandbox_MultiFile_SingleVol_6.bak',
	DISK = N'\\10.21.200.74\ayun-sql-backups\Sandbox_MultiFile_SingleVol_7.bak',
	DISK = N'\\10.21.200.75\ayun-sql-backups\Sandbox_MultiFile_SingleVol_8.bak'
WITH COPY_ONLY, FORMAT, INIT,
	COMPRESSION (ALGORITHM = QAT_DEFLATE),	-- QAT compression
	BUFFERCOUNT = 100,
	MAXTRANSFERSIZE = 4194304,
	STATS = 15
GO 








------
-- Let's look at the output backup file sizes
SELECT DISTINCT 
	backupset.database_name,
	backupset.Backup_Start_Date,
	DATEDIFF(ms, backupset.backup_start_date, backupset.backup_finish_date) AS ms_taken,
	CONVERT(decimal(10, 2), backupset.backup_size/1024./1024.) AS backup_size_mb,
	CONVERT(decimal(10, 2), backupset.compressed_backup_size/1024./1024.) AS comp_backup_size_mb,
	backupset.compression_algorithm
	--bs.flags, bs.description, bms.description, bs.name, bms.name
FROM msdb.dbo.backupset
WHERE backupset.backup_start_date > DATEADD(HOUR, -1, sysdatetime()) --only look at last 1 hour
ORDER BY backupset.Backup_Start_Date DESC
GO



