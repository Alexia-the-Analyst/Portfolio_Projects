--Utilized a join to list the school names, community names and average attendance for communities with a hardship index of 98.
select NAME_OF_SCHOOL as SCHOOL_NAME, CENSUS_DATA.COMMUNITY_AREA_NAME, AVERAGE_STUDENT_ATTENDANCE
from CHICAGO_PUBLIC_SCHOOLS
left outer join CENSUS_DATA
on CHICAGO_PUBLIC_SCHOOLS.COMMUNITY_AREA_NUMBER = CENSUS_DATA.COMMUNITY_AREA_NUMBER
where HARDSHIP_INDEX = 98;

--Created a query to list all crimes that took place at a school. Included case number, crime type and community name.
select CASE_NUMBER, PRIMARY_TYPE as CRIME_TYPE, CENSUS_DATA.COMMUNITY_AREA_NAME
from CHICAGO_CRIME_DATA
left outer join CENSUS_DATA
on CHICAGO_CRIME_DATA.COMMUNITY_AREA_NUMBER = CENSUS_DATA.COMMUNITY_AREA_NUMBER
where LOCATION_DESCRIPTION like '%SCHOOL%'; 

-- Created a view that enables users to select just the school name and the icon fields from the CHICAGO_PUBLIC_SCHOOLS table
CREATE VIEW CPS_VIEWS AS SELECT
	NAME_OF_SCHOOL AS School_Name, 
	Safety_Icon AS Safety_Rating, 
	Family_Involvement_Icon as Family_Rating, 
	Environment_Icon AS Environment_Rating,
	Instruction_Icon AS Instruction_Rating,
	Leaders_Icon AS Leaders_Rating,
	Teachers_Icon AS Teachers_Rating
FROM CHICAGO_PUBLIC_SCHOOLS;

-- Viewing all columns in the newly created view.
select * 
from CPS_VIEWS;

--Viewing only the school name and leaders rating from the view.
select SCHOOL_NAME, LEADERS_RATING
FROM CPS_VIEWS;

--Creating a Stored Procedure
--#SET TERMINATOR @
	CREATE PROCEDURE UPDATE_LEADERS_SCORE (
		IN in_School_ID INTEGER, IN in_Leader_Score INTEGER
	)
	
	LANGUAGE SQL
	MODIFIES SQL DATA
	
	BEGIN
		-- Updating the Leaders_Score FIELD
		UPDATE CHICAGO_PUBLIC_SCHOOLS
		SET Leaders_Score = in_Leader_Score
		Where School_ID = in_School_ID;
		
		-- Updating the Leaders_Icon field based on score ranges
		IF in_Leader_Score >= 0 AND in_Leader_Score < 20 THEN
			UPDATE CHICAGO_PUBLIC_SCHOOLS
			SET Leaders_Icon = 'Very weak'
			WHERE School_ID = in_School_ID;
		
		ELSEIF in_Leader_Score >= 20 AND in_Leader_Score < 40 THEN
			UPDATE CHICAGO_PUBLIC_SCHOOLS
			SET Leaders_Icon = 'Weak'
			WHERE School_ID = in_School_ID;
		
		ELSEIF in_Leader_Score >= 40 AND in_Leader_Score < 60 THEN
			UPDATE CHICAGO_PUBLIC_SCHOOLS
			SET Leaders_Icon = 'Avg'
			WHERE School_ID = in_School_ID;
		
		ELSEIF in_Leader_Score >= 60 AND in_Leader_Score < 80 THEN
			UPDATE CHICAGO_PUBLIC_SCHOOLS
			SET Leaders_Icon = 'Strong'
			WHERE School_ID = in_School_ID;
		
		ELSEIF in_Leader_Score >= 0 AND in_Leader_Score < 20 THEN
			UPDATE CHICAGO_PUBLIC_SCHOOLS
			SET Leaders_Icon = 'Very strong'
			WHERE School_ID = in_School_ID;
			
		ELSE
			-- Rollback if the score is invalid
			ROLLBACK;
		
			-- Commit the transaction
			COMMIT;
		END IF;
	
	END
	@

-- Calling Stored Procedure
CALL UPDATE_LEADERS_SCORE(610281, 58)
