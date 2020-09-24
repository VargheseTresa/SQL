--Questions and Answers for CentralPark Database

use CentralPark
GO

--Q1:  Who are the people who have not paid for the fine more than 3 times?
Select NOTICE_LICENCE_PLATE
from NOTICE
	GROUP BY NOTICE_LICENCE_PLATE
	HAVING COUNT(NOTICE_LICENCE_PLATE) >3
	ORDER BY COUNT(NOTICE_LICENCE_PLATE)

--A1: There are no repeat offenders.

--Q2: Where is the parking location that had the most number of fines?

SELECT LOCATION.LOC_NAME AS 'Location Name', COUNT(LOCATION.LOC_NUM) as 'Number of Fines'
FROM NOTICE JOIN LOCATION ON LOCATION.LOC_NUM = NOTICE.LOC_NUM
GROUP BY NOTICE.LOC_NUM, LOCATION.LOC_NAME
HAVING COUNT(LOCATION.LOC_NUM) = (SELECT TOP 1 COUNT(LOC_NUM)
                                FROM NOTICE
                                GROUP BY LOC_NUM
                                ORDER BY COUNT(LOC_NUM) DESC);

--A2: Kingsroad Station location has had the most number of fines.

--Q3: Which day and time of the day are the peak times for purchases?

SELECT TRANS_TIME, COUNT(*) as 'Purchase Time Frequency'
FROM TRANSACTIONS
GROUP BY TRANS_TIME
ORDER BY COUNT(*) DESC

--A3: Based on the organization of the transaction time, two purchases occured on March 8th 2018 at ~9am, March 6th 8 am, March 5th 3pm and march 3rd 1pm resulting in the peak date and time for purchase.


--Q4. How many patrollers is the most cost effective to hire in each time window?

SELECT EMP_ID, COUNT(INFRACTION_DETAILS) as 'NUMBER OF INFRACTIONS'
FROM INFRACTION_LINE
GROUP BY EMP_ID
ORDER BY COUNT(INFRACTION_DETAILS) DESC

--	A4: Based on the employee that was able to apply the highest number of infractions, we could determine the most cost effective for the operations.

--Q5. Are we breaking even? Should we increase or decrease the rate?


SELECT LOC_NUM, SUM(TRANS_PAY_AMOUNT) as "Revenue"
FROM TRANSACTIONS
GROUP BY LOC_NUM
ORDER BY SUM(TRANS_PAY_AMOUNT) DESC;

--A5 Based on review of revenue for each location, we can make decisions on rate increase/decrease

--Q6. Location with the highest revenue?


SELECT TOP 1 TRANSACTIONS.LOC_NUM, LOC_NAME, SUM (TRANS_PAY_AMOUNT) AS 'REVENUE'
FROM TRANSACTIONS JOIN LOCATION ON LOCATION.LOC_NUM = TRANSACTIONS.LOC_NUM
GROUP BY TRANSACTIONS.LOC_NUM, LOC_NAME
ORDER BY SUM (TRANS_PAY_AMOUNT) DESC;

--A6: Location 1 has the highest revenue.


--Q7. Which payment type is most common?

SELECT TRANS_PAY_TYPE AS 'Payment Type', COUNT(TRANS_PAY_TYPE) as 'Number of payments'
FROM TRANSACTIONS
GROUP BY TRANS_PAY_TYPE
HAVING COUNT(TRANS_PAY_TYPE) = (SELECT TOP 1 COUNT(TRANS_PAY_TYPE)
								FROM TRANSACTIONS
								GROUP BY TRANS_PAY_TYPE
								ORDER BY COUNT(TRANS_PAY_TYPE) DESC);

--A7: Cash is the most common payment type.

--Q8. Location with the most patrol visits

SELECT L.LOC_NAME AS'Location Name', COUNT(V.LOC_NUM) AS 'Number of visits'
FROM VISIT_LOG  V JOIN LOCATION  L ON L.LOC_NUM = V.LOC_NUM
GROUP BY V.LOC_NUM,L.LOC_NAME
HAVING COUNT(L.LOC_NUM)=(SELECT TOP 1 COUNT(LOC_NUM) 
						FROM VISIT_LOG
						GROUP BY LOC_NUM
						ORDER BY COUNT(LOC_NUM) DESC);

--A8: Cipher Publishing has the most patrol visits (3).


--Q9. Which rates are the least popular per location?

  SELECT TRANS_PAY_AMOUNT, COUNT(TRANS_PAY_AMOUNT) as 'RATE OCCURANCY'
  FROM TRANSACTIONS
  GROUP BY TRANS_PAY_AMOUNT
  ORDER BY 'RATE OCCURANCY' ASC
	
-- A9: Based on the results we could see that the 12.5, 7.00, 10.50 and 14.00 are the least populat rates, and the 3.50 is the most used with 5 occurancies.


--Q10. How many EV stall per location?

--A10: Stall types have not been defined, and therefore no EV stall information available. Cannot answer this question. 


--Q11. How many stall are there per location?
SELECT LOC_NAME, LOC_STALLS AS 'Number of stalls'
FROM LOCATION
ORDER BY LOC_NAME;


--Q12. How many locations does Darlene Rollins manage?


SELECT EMP_ID, COUNT(LOC_NUM) as "Number of Locations Managed" 
FROM MANAGER_LOCATION 
WHERE EMP_ID = (SELECT EMP_ID FROM EMPLOYEE WHERE EMP_FNAME = 'Darlene' AND EMP_LNAME = 'Rollins')
GROUP BY EMP_ID;

--A12: Darlene Rollins Manages two locations.

--Q13. List all the properties by a single client
--Q13a. List all the properties by client 4 (for example)

select CLIENT_ID, LOC_NUM, LOC_NAME
from LOCATION

select CLIENT_ID, LOC_NUM, LOC_NAME
from LOCATION
where CLIENT_ID=4

--A13. client 4 owns one property.


--Q14. (NEW) List the total number of payments done via each payment type

SELECT TRANS_PAY_TYPE, COUNT(TRANS_PAY_TYPE) as 'Number of payments'
FROM TRANSACTIONS
GROUP BY TRANS_PAY_TYPE
ORDER BY COUNT(TRANS_PAY_TYPE) DESC;


--Q15. (NEW) List summary details of all the properties owned by client Ranchero

SELECT LOC_NAME AS 'Location Name', LOC_STALLS AS 'Number of Stalls'
FROM LOCATION JOIN CLIENT ON LOCATION.CLIENT_ID = CLIENT.CLIENT_ID
WHERE CLIENT_BUS_NAME = 'Ranchero';