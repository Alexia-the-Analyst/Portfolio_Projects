/* Review and Join Employee Data Tables Using Multiple Join Operations*/

--Select the names and job start dates of all employees who work for department number 5. 
select E.F_NAME, E.L_NAME, JH.START_DATE
from EMPLOYEES as E
INNER JOIN JOB_HISTORY as JH on E.EMP_ID=JH.EMPL_ID
where E.DEP_ID = '5';

-- Select the names, job start dates, and job titles of all employees who work for department number 5.
select E.F_NAME, E.L_NAME, JH.START_DATE, J.JOB_TITLE
from EMPLOYEES as E
INNER JOIN JOB_HISTORY as JH on E.EMP_ID=JH.EMPL_ID
INNER JOIN JOBS as J on E.JOB_ID=J.JOB_IDENT
where E.DEP_ID = '5';

-- Complete a left outer join on the Employees and Department tables and select employee id, last name, department id and department name for all employees.
select E.EMP_ID, E.L_NAME, E.DEP_ID, D.DEP_NAME 
from EMPLOYEES as E
LEFT OUTER JOIN DEPARTMENTS as D on E.DEP_ID=D.DEPT_ID_DEP; 

-- Rewrite previous query to limit the result set to include only the rows for employees born before 1980.
select E.EMP_ID, E.L_NAME, E.DEP_ID, D.DEP_NAME 
from EMPLOYEES as E
LEFT OUTER JOIN DEPARTMENTS as D on E.DEP_ID=D.DEPT_ID_DEP
where YEAR(E.B_DATE) < 1980; 

-- Rewrite previous query to include all employees, but department names only for the employees born before 1980.
select E.EMP_ID, E.L_NAME, E.DEP_ID, D.DEP_NAME 
from EMPLOYEES as E
LEFT OUTER JOIN DEPARTMENTS as D on E.DEP_ID=D.DEPT_ID_DEP
and YEAR(E.B_DATE) < 1980;

-- Perform a full join on the Employees and Deparment tables and select the First Name, Last Name, and Department name of all employees.
select E.F_NAME, E.L_NAME, D.DEP_NAME 
from EMPLOYEES as E
FULL OUTER JOIN DEPARTMENTS as D on E.DEP_ID=D.DEPT_ID_DEP;

-- Rewrite the previous query to return a result set that includea all employee names, but department id and department names for male employees only.
select E.F_NAME, E.L_NAME, E.DEP_ID, D.DEP_NAME
from EMPLOYEES as E
FULL OUTER JOIN DEPARTMENTS as D on E.DEP_ID=D.DEPT_ID_DEP and E.SEX = 'M';
