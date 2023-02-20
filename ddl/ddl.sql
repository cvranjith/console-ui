CREATE TABLE "CONSOLE_LOGS_ARCH" 
   (	"LOG_ID" NUMBER(*,0), 
	"LOG_TIME" TIMESTAMP (6) WITH LOCAL TIME ZONE, 
	"LEVEL_ID" NUMBER(1,0), 
	"LEVEL_NAME" VARCHAR2(10 BYTE), 
	"PERMANENT" VARCHAR2(1 BYTE), 
	"SCOPE" VARCHAR2(256 BYTE), 
	"MESSAGE" CLOB, 
	"ERROR_CODE" NUMBER(10,0), 
	"CALL_STACK" VARCHAR2(4000 BYTE), 
	"SESSION_USER" VARCHAR2(32 BYTE), 
	"MODULE" VARCHAR2(48 BYTE), 
	"ACTION" VARCHAR2(32 BYTE), 
	"CLIENT_INFO" VARCHAR2(64 BYTE), 
	"CLIENT_IDENTIFIER" VARCHAR2(64 BYTE), 
	"IP_ADDRESS" VARCHAR2(48 BYTE), 
	"HOST" VARCHAR2(64 BYTE), 
	"OS_USER" VARCHAR2(64 BYTE), 
	"OS_USER_AGENT" VARCHAR2(200 BYTE), 
	"ARCHIVED" VARCHAR2(1 BYTE)
   ) ;

ALTER TABLE "CONSOLE_LOGS_ARCH" MODIFY ("LOG_ID" NOT NULL ENABLE);

ALTER TABLE "CONSOLE_LOGS_ARCH" MODIFY ("LOG_TIME" NOT NULL ENABLE);

ALTER TABLE "CONSOLE_LOGS_ARCH" MODIFY ("LEVEL_ID" NOT NULL ENABLE);

ALTER TABLE "CONSOLE_LOGS_ARCH" MODIFY ("LEVEL_NAME" NOT NULL ENABLE);

ALTER TABLE "CONSOLE_LOGS_ARCH" MODIFY ("PERMANENT" NOT NULL ENABLE);


CREATE OR REPLACE FORCE EDITIONABLE VIEW "VW_CONSOLE_LOGS" ("ID", "ACT", "RID", "ARCHIVED", "LOG_ID", "LOG_TIME", "LEVEL_ID", "LEVEL_NAME", "PERMANENT", "SCOPE", "MESSAGE", "ERROR_CODE", "CALL_STACK", "SESSION_USER", "MODULE", "ACTION", "CLIENT_INFO", "CLIENT_IDENTIFIER", "IP_ADDRESS", "HOST", "OS_USER", "OS_USER_AGENT") AS 
  select nvl(nvl( client_info ,
  --(case when client_identifier like '{o,o}%' then substr(client_identifier,7) else client_identifier end)
   --||'_'||
   session_user|| '_' || to_char(log_time,'YYYY-MM-DD-HH24')), 'undefined' ) id,
        nvl(action,'undef') act,
        a.rowid rid,
        nvl(a.archived,'N') archived,
         a."LOG_ID",a."LOG_TIME",a."LEVEL_ID",a."LEVEL_NAME",a."PERMANENT",a."SCOPE",a."MESSAGE",a."ERROR_CODE",a."CALL_STACK",a."SESSION_USER",a."MODULE",a."ACTION",a."CLIENT_INFO",a."CLIENT_IDENTIFIER",a."IP_ADDRESS",a."HOST",a."OS_USER",a."OS_USER_AGENT"
from console.console_logs a
--where nvl(archived,'N') != 'Y'
;
CREATE OR REPLACE FORCE EDITIONABLE VIEW "VW_CONSOLE_LOGS_ARCH" ("ID", "ACT", "RID", "ARCHIVED", "LOG_ID", "LOG_TIME", "LEVEL_ID", "LEVEL_NAME", "PERMANENT", "SCOPE", "MESSAGE", "ERROR_CODE", "CALL_STACK", "SESSION_USER", "MODULE", "ACTION", "CLIENT_INFO", "CLIENT_IDENTIFIER", "IP_ADDRESS", "HOST", "OS_USER", "OS_USER_AGENT") AS 
select nvl(nvl( client_info ,
  --(case when client_identifier like '{o,o}%' then substr(client_identifier,7) else client_identifier end)
   --||'_'||
   session_user|| '_' || to_char(log_time,'YYYY-MM-DD-HH24')), 'undefined' ) id,
        nvl(action,'undef') act,
        a.rowid rid,
        nvl(a.archived,'N') archived,
         a."LOG_ID",a."LOG_TIME",a."LEVEL_ID",a."LEVEL_NAME",a."PERMANENT",a."SCOPE",a."MESSAGE",a."ERROR_CODE",a."CALL_STACK",a."SESSION_USER",a."MODULE",a."ACTION",a."CLIENT_INFO",a."CLIENT_IDENTIFIER",a."IP_ADDRESS",a."HOST",a."OS_USER",a."OS_USER_AGENT"
from console_logs_arch a
--where nvl(archived,'N') != 'Y'
;


CREATE OR REPLACE FORCE EDITIONABLE VIEW "VW_CONSOLE_LOGS_SUMM1" ("ID", "LOG_TIME", "ACT") AS 
  select id, max(log_time) log_time, act
from vw_console_logs
group by id,act
;


CREATE OR REPLACE FORCE EDITIONABLE VIEW "VW_CONSOLE_LOGS_SUMM1_ARCH" ("ID", "LOG_TIME", "ACT") AS 
  select id, max(log_time) log_time, act
from vw_console_logs_arch
group by id,act
;


CREATE OR REPLACE FORCE EDITIONABLE VIEW "VW_CONSOLE_LOGS_SUMM2" ("ID", "LOG_TIME", "ARCHIVED") AS 
  select id, max(log_time) log_time, max(archived) archived
from vw_console_logs
group by id
;

CREATE OR REPLACE FORCE EDITIONABLE VIEW "VW_CONSOLE_LOGS_SUMM2_ARCH" ("ID", "LOG_TIME", "ARCHIVED") AS 
  select id, max(log_time) log_time, max(archived) archived
from vw_console_logs_arch
group by id
;

