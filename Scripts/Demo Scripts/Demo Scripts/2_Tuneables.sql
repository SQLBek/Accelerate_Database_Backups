/*-------------------------------------------------------------------
-- 2 - Data Transfer Tuneables
-- 
-- Summary: 
--
-- Written By: Andy Yun
-------------------------------------------------------------------*/
-----
-- Reset Trace Flags
DBCC TRACEOFF(3604, 3004, 3014, 3213, -1);
GO
DBCC TRACEON(3604, 3004, 3213, -1);
GO








------
-- Baseline again
PRINT '---'
BACKUP DATABASE Sandbox_MultiFile_SingleVol TO
	DISK='NUL'
WITH COPY_ONLY, FORMAT, INIT,
	STATS = 15
GO 

PRINT '---'
BACKUP DATABASE Sandbox_MultiFile_MultiVol TO
	DISK='NUL'
WITH COPY_ONLY, FORMAT, INIT,
	STATS = 15
GO 

/*
-- Record best case scenario here:
SingleVol:
Number of data file readers = 1
BufferCount:                xx
MaxTransferSize:            xxxx KB
Total buffer space:         xx MB
Effective options: Checksum=x, Compression=x, Encryption=x, BufferCount=x, MaxTransferSize=x KB
Number of data file readers = x
BACKUP DATABASE successfully processed xxx pages in xxx seconds (xxx MB/sec).

MultiVol:
BufferCount:                xx
MaxTransferSize:            xxxx KB
Total buffer space:         xx MB
Effective options: Checksum=x, Compression=x, Encryption=x, BufferCount=x, MaxTransferSize=x KB
Number of data file readers = x
BACKUP DATABASE successfully processed xxx pages in xxx seconds (xxx MB/sec).
*/








------
-- Let's actually do a backup
-- Turn off TF's, don't want the extra diag info just yet
DBCC TRACEOFF(3604, 3004, 3014, 3213, -1);
GO
PRINT '---'
BACKUP DATABASE Sandbox_MultiFile_SingleVol TO
	DISK = N'\\10.21.200.27\ayun-sql-backups\Sandbox_MultiFile_SingleVol_1.bak'
WITH COPY_ONLY, FORMAT, INIT,
	STATS = 15
GO 

PRINT '---'
BACKUP DATABASE Sandbox_MultiFile_MultiVol TO
	DISK = N'\\10.21.200.27\ayun-sql-backups\Sandbox_MultiFile_MultiVol_1.bak'
WITH COPY_ONLY, FORMAT, INIT,
	STATS = 15
GO 


-- Why wasn't multi-file faster?
-- We have more reader threads.








-----
-- Let's check wait stats!
-- Refer to 2a_WaitStatistics.sql








-----
-- Clear sys.dm_os_wait_stats
DBCC SQLPERF (N'sys.dm_os_wait_stats', CLEAR);
GO

PRINT '---'
BACKUP DATABASE Sandbox_MultiFile_MultiVol TO
	DISK = N'\\10.21.200.27\ayun-sql-backups\Sandbox_MultiFile_MultiVol_1.bak'
WITH COPY_ONLY, FORMAT, INIT,
	STATS = 15
GO 


-----
-- Check wait stats via 2a_WaitStatistics.sql








-----
-- Increase BufferCount
-- Clear sys.dm_os_wait_stats
DBCC SQLPERF (N'sys.dm_os_wait_stats', CLEAR);
GO

PRINT '---'
BACKUP DATABASE Sandbox_MultiFile_MultiVol TO
	DISK = N'\\10.21.200.27\ayun-sql-backups\Sandbox_MultiFile_MultiVol_1.bak'
WITH COPY_ONLY, FORMAT, INIT,
	BUFFERCOUNT = 500,
	STATS = 15
GO 


-- Did this help?
-- Throughput?  Wait times?








-----
-- Crank BUFFERCOUNT way up
DBCC SQLPERF (N'sys.dm_os_wait_stats', CLEAR);
GO

PRINT '---'
BACKUP DATABASE Sandbox_MultiFile_MultiVol TO
	DISK = N'\\10.21.200.27\ayun-sql-backups\Sandbox_MultiFile_MultiVol_1.bak'
WITH COPY_ONLY, FORMAT, INIT,
	BUFFERCOUNT = 2500,
	STATS = 15
GO 


-- Did this help?
-- Throughput?  Wait times?








-----
-- Let's add writer threads to process backup buffers!
DBCC SQLPERF (N'sys.dm_os_wait_stats', CLEAR);
GO

PRINT '--- 4 backup files/writer threads ---'
BACKUP DATABASE Sandbox_MultiFile_MultiVol TO
	DISK = N'\\10.21.200.27\ayun-sql-backups\Sandbox_MultiFile_MultiVol_1.bak',
	DISK = N'\\10.21.200.28\ayun-sql-backups\Sandbox_MultiFile_MultiVol_2.bak',
	DISK = N'\\10.21.200.70\ayun-sql-backups\Sandbox_MultiFile_MultiVol_3.bak',
	DISK = N'\\10.21.200.71\ayun-sql-backups\Sandbox_MultiFile_MultiVol_4.bak'
WITH COPY_ONLY, FORMAT, INIT,
	BUFFERCOUNT = 500,
	STATS = 15
GO 


-- Did this help?
-- Throughput?  Wait times?








-----
-- Larger I/O sizes
DBCC SQLPERF (N'sys.dm_os_wait_stats', CLEAR);
GO

PRINT '--- 4 backup files/writer threads ---'
BACKUP DATABASE Sandbox_MultiFile_MultiVol TO
	DISK = N'\\10.21.200.27\ayun-sql-backups\Sandbox_MultiFile_MultiVol_1.bak',
	DISK = N'\\10.21.200.28\ayun-sql-backups\Sandbox_MultiFile_MultiVol_2.bak',
	DISK = N'\\10.21.200.70\ayun-sql-backups\Sandbox_MultiFile_MultiVol_3.bak',
	DISK = N'\\10.21.200.71\ayun-sql-backups\Sandbox_MultiFile_MultiVol_4.bak'
WITH COPY_ONLY, FORMAT, INIT,
	BUFFERCOUNT = 500,
	MAXTRANSFERSIZE = 2097152,
	STATS = 15
GO 


-- Did this help throughput?  








-----
-- Let's add more writer threads to process backup buffers!
PRINT '--- 8 backup files/writer threads ---'
BACKUP DATABASE Sandbox_MultiFile_MultiVol TO
	DISK = N'\\10.21.200.27\ayun-sql-backups\Sandbox_MultiFile_MultiVol_1.bak',
	DISK = N'\\10.21.200.28\ayun-sql-backups\Sandbox_MultiFile_MultiVol_2.bak',
	DISK = N'\\10.21.200.70\ayun-sql-backups\Sandbox_MultiFile_MultiVol_3.bak',
	DISK = N'\\10.21.200.71\ayun-sql-backups\Sandbox_MultiFile_MultiVol_4.bak',
	DISK = N'\\10.21.200.72\ayun-sql-backups\Sandbox_MultiFile_MultiVol_5.bak',
	DISK = N'\\10.21.200.73\ayun-sql-backups\Sandbox_MultiFile_MultiVol_6.bak',
	DISK = N'\\10.21.200.74\ayun-sql-backups\Sandbox_MultiFile_MultiVol_7.bak',
	DISK = N'\\10.21.200.75\ayun-sql-backups\Sandbox_MultiFile_MultiVol_8.bak'
WITH COPY_ONLY, FORMAT, INIT,
	BUFFERCOUNT = 500,
	MAXTRANSFERSIZE = 2097152,
	STATS = 15
GO 


-- Did this help throughput?  








-----
-- Max out MAXTRANSFERSIZE?
PRINT '--- 8 backup files/writer threads ---'
BACKUP DATABASE Sandbox_MultiFile_MultiVol TO
	DISK = N'\\10.21.200.27\ayun-sql-backups\Sandbox_MultiFile_MultiVol_1.bak',
	DISK = N'\\10.21.200.28\ayun-sql-backups\Sandbox_MultiFile_MultiVol_2.bak',
	DISK = N'\\10.21.200.70\ayun-sql-backups\Sandbox_MultiFile_MultiVol_3.bak',
	DISK = N'\\10.21.200.71\ayun-sql-backups\Sandbox_MultiFile_MultiVol_4.bak',
	DISK = N'\\10.21.200.72\ayun-sql-backups\Sandbox_MultiFile_MultiVol_5.bak',
	DISK = N'\\10.21.200.73\ayun-sql-backups\Sandbox_MultiFile_MultiVol_6.bak',
	DISK = N'\\10.21.200.74\ayun-sql-backups\Sandbox_MultiFile_MultiVol_7.bak',
	DISK = N'\\10.21.200.75\ayun-sql-backups\Sandbox_MultiFile_MultiVol_8.bak'
WITH COPY_ONLY, FORMAT, INIT,
	BUFFERCOUNT = 500,
	MAXTRANSFERSIZE = 4194304,
	STATS = 15
GO 

PRINT ''
PRINT '--- 8 backup files/writer threads ---'
BACKUP DATABASE Sandbox_MultiFile_MultiVol TO
	DISK = N'\\10.21.200.27\ayun-sql-backups\Sandbox_MultiFile_MultiVol_1.bak',
	DISK = N'\\10.21.200.28\ayun-sql-backups\Sandbox_MultiFile_MultiVol_2.bak',
	DISK = N'\\10.21.200.70\ayun-sql-backups\Sandbox_MultiFile_MultiVol_3.bak',
	DISK = N'\\10.21.200.71\ayun-sql-backups\Sandbox_MultiFile_MultiVol_4.bak',
	DISK = N'\\10.21.200.72\ayun-sql-backups\Sandbox_MultiFile_MultiVol_5.bak',
	DISK = N'\\10.21.200.73\ayun-sql-backups\Sandbox_MultiFile_MultiVol_6.bak',
	DISK = N'\\10.21.200.74\ayun-sql-backups\Sandbox_MultiFile_MultiVol_7.bak',
	DISK = N'\\10.21.200.75\ayun-sql-backups\Sandbox_MultiFile_MultiVol_8.bak'
WITH COPY_ONLY, FORMAT, INIT,
	BUFFERCOUNT = 2500,
	MAXTRANSFERSIZE = 4194304,
	STATS = 15
GO 

-- Did that help throughput?
--
-- If you have SQL monitoring tracking wait statistics, and your backup related stats 
-- have relatively HIGH values, especially compared to your workload's wait stats, then 
-- you MIGHT have cause for concern.
-- Remember waits of some sort will ALWAYS happen
