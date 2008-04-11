/* =============================================================================== */
/* SCHEMA: RMSAUTO@idcdev.ctbto.org                                                */
/* AUTHOR: guillaume.aubert@ctbto.org
/* DATE	 : 22.01.2008	                                                             */
/* =============================================================================== */

/* =============================================================================== */
/* Tablespaces                                                                     */
/* =============================================================================== */

CREATE TABLESPACE RMS
  EXTENT MANAGEMENT LOCAL
  SEGMENT SPACE MANAGEMENT AUTO
  DATAFILE 'rmsdata.dbf' SIZE 20M REUSE;

/* =============================================================================== */
/* Create User                                                                     */
/* =============================================================================== */

-- DROP USER RMSAUTO CASCADE;
CREATE USER RMSAUTO
  IDENTIFIED BY RMSAUTO   /* xxx please change password */
  DEFAULT TABLESPACE RMS
/

ALTER USER RMSAUTO QUOTA UNLIMITED ON RMS
/

CREATE USER RMSMAN
  IDENTIFIED BY RMSMAN   /* xxx please change password */
  DEFAULT TABLESPACE RMS
/

ALTER USER RMSMAN QUOTA UNLIMITED ON RMS
/

/* =============================================================================== */
/* Grant System and Role Privileges                                                */
/* =============================================================================== */

GRANT ADVISOR TO RMSAUTO
/

GRANT ALTER SESSION TO RMSAUTO
/

GRANT CREATE ANY SQL PROFILE TO RMSAUTO
/

GRANT CREATE CLUSTER TO RMSAUTO
/

GRANT CREATE DATABASE LINK TO RMSAUTO
/

GRANT CREATE PROCEDURE TO RMSAUTO
/

GRANT CREATE SEQUENCE TO RMSAUTO
/

GRANT CREATE SESSION TO RMSAUTO
/

GRANT CREATE SYNONYM TO RMSAUTO
/

GRANT CREATE TABLE TO RMSAUTO
/

GRANT CREATE TRIGGER TO RMSAUTO
/

GRANT CREATE VIEW TO RMSAUTO
/

GRANT ADVISOR TO RMSMAN
/

GRANT ALTER SESSION TO RMSMAN
/

GRANT CREATE ANY SQL PROFILE TO RMSMAN
/

GRANT CREATE CLUSTER TO RMSMAN
/

GRANT CREATE DATABASE LINK TO RMSMAN
/

GRANT CREATE PROCEDURE TO RMSMAN
/

GRANT CREATE SEQUENCE TO RMSMAN
/

GRANT CREATE SESSION TO RMSMAN
/

GRANT CREATE SYNONYM TO RMSMAN
/

GRANT CREATE TABLE TO RMSMAN
/

GRANT CREATE TRIGGER TO RMSMAN
/

GRANT CREATE VIEW TO RMSMAN
/
