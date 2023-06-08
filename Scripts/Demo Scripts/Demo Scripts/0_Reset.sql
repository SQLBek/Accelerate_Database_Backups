/*-------------------------------------------------------------------
-- 0 - Reset
-- 
-- Summary: 
--
-- Written By: Andy Yun
-------------------------------------------------------------------*/
DBCC TRACEOFF(3604, 3004, 3014, 3213, -1);
GO

-----
-- Check current state of QAT on SQLFB
SELECT * 
FROM sys.dm_server_accelerator_status;
GO

/*
-- Software Mode - must restart SQL Services
ALTER SERVER CONFIGURATION
SET HARDWARE_OFFLOAD = ON (ACCELERATOR = QAT, MODE = SOFTWARE)
GO
*/