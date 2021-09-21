/*DDL PART*/
CREATE TABLE CUSTOMER (
  C_ID VARCHAR(100) NOT NULL,
  FIRST_NAME VARCHAR(100),
  LAST_NAME VARCHAR(100),
  EMAIL VARCHAR(100),
  MOBILE_NUM VARCHAR(100),
  ADDRESS VARCHAR(100),
  GENDER VARCHAR(100),
  DOB DATE,
  DATE_OF_REG DATE,
  POSTAL_CODE VARCHAR(100),
  PRIMARY KEY (C_ID)
);

CREATE TABLE FACILITY (
  FACILITY_ID VARCHAR(100) NOT NULL,
  FACILITY_DESC VARCHAR(1000),
  FACILITY_TYPE VARCHAR(100),
  FACILITY_CAPACITY INT,
  FACILITY_SUBTYPE VARCHAR(1000),
  LOCATION VARCHAR(100),
  PRIMARY KEY (FACILITY_ID)
);

CREATE TABLE PAYMENT_METHOD (
  PAYMENT_METHOD_ID INT NOT NULL,
  PAYMENT_METHOD_DESC VARCHAR(100),
  PRIMARY KEY (PAYMENT_METHOD_ID)
);

CREATE TABLE PAYMENT (
  PAYMENT_ID INT NOT NULL,
  PAYMENT_METHOD_ID INT,
  PROMO_APPLIED INT(1),
  PRICE INT,
  PURCHASE_MODE VARCHAR(100),
  PRIMARY KEY (PAYMENT_ID),
  FOREIGN KEY (PAYMENT_METHOD_ID) REFERENCES PAYMENT_METHOD(PAYMENT_METHOD_ID)
);

CREATE TABLE TICKET_CATEGORY (
  CATEGORY_OF_TICKET_ID INT(1) NOT NULL,
  CATEGORY_OF_TICKET_DESC VARCHAR(100),
  PRIMARY KEY (CATEGORY_OF_TICKET_ID)
);

CREATE TABLE RIDE (
  RIDE_ID VARCHAR(100) NOT NULL,
  RIDE_NAME VARCHAR(100),
  TYPE_OF_RIDE VARCHAR(100),
  CAPACITY_OF_A_RIDE DOUBLE,
  RIDE_HEIGHT DOUBLE,
  YEARS_STARTED DOUBLE,
  DESCRIPTION VARCHAR(10000),
  MIN_RIDE_HEIGHT VARCHAR(1000),
   MANUFACTURER VARCHAR(100),
  `TOP_SPEED(MPH)` DOUBLE,
  `TRACK_LENGTH(FT)` DOUBLE,
  ADDITIONAL_FEES VARCHAR(1),
  PRIMARY KEY (RIDE_ID)
);

CREATE TABLE TICKET (
  TICKET_ID INT NOT NULL,
  C_ID VARCHAR(100),
  PAYMENT_ID INT NOT NULL,
  `CATEGORY_OF_TICKET_ID` INT(1),
    PURCHASE_DATE DATE,
  PRIMARY KEY (TICKET_ID, C_ID, PAYMENT_ID, `CATEGORY_OF_TICKET_ID`, PURCHASE_DATE),
  FOREIGN KEY (PAYMENT_ID) REFERENCES PAYMENT(PAYMENT_ID),
  FOREIGN KEY (C_ID) REFERENCES CUSTOMER(C_ID),
  FOREIGN KEY (`CATEGORY_OF_TICKET_ID`) REFERENCES `ticket_category`(`CATEGORY_OF_TICKET_ID`)
);


CREATE TABLE TICKET_RIDE(
RIDE_TICKET_ID INT NOT NULL,
RIDE_ID VARCHAR(100),
TICKET_ID INT,
TIMESTAMP DATETIME,
PRIMARY KEY (RIDE_TICKET_ID),
FOREIGN KEY (TICKET_ID) REFERENCES TICKET(TICKET_ID),
FOREIGN KEY (RIDE_ID) REFERENCES RIDE(RIDE_ID)
); 

CREATE TABLE TICKET_FACILITY(
FACILITY_TICKET_ID INT NOT NULL,
TICKET_ID INT,
FACILITY_ID VARCHAR(100),
TIMESTAMP DATETIME,
PRIMARY KEY (FACILITY_TICKET_ID),
FOREIGN KEY (TICKET_ID) REFERENCES TICKET(TICKET_ID),
FOREIGN KEY (FACILITY_ID) REFERENCES FACILITY(FACILITY_ID)
); 




/*the following is the query to manipulate RIDE table*/
/*I first use python to upload ride.csv to ride2 table in db, then use sql to fillna
then use sql to fill ride with ride2's data*/
/*I will also submit the python files I used to preprocess each table*/
UPDATE ride2
SET ride2.MIN_RIDE_HEIGHT= NULL
WHERE ride2.MIN_RIDE_HEIGHT='';

UPDATE ride2
SET ride2.CAPACITY_OF_A_RIDE= NULL
WHERE ride2.CAPACITY_OF_A_RIDE='';

UPDATE ride2
SET ride2.RIDE_HEIGHT= NULL
WHERE ride2.RIDE_HEIGHT='';


UPDATE ride2
SET ride2.YEARS_STARTED= NULL
WHERE ride2.YEARS_STARTED='';

UPDATE ride2
SET ride2.MANUFACTURER= NULL
WHERE ride2.MANUFACTURER='';

UPDATE ride2
SET ride2.`TOP_SPEED(MPH)`= NULL
WHERE ride2.`TOP_SPEED(MPH)`='';

UPDATE ride2
SET ride2.`TRACK_LENGTH(FT)`= NULL
WHERE ride2.`TRACK_LENGTH(FT)`='';



INSERT INTO 
RIDE (RIDE_ID,`RIDE_NAME`,`TYPE_OF_RIDE`,`CAPACITY_OF_A_RIDE`,`RIDE_HEIGHT`,`YEARS_STARTED`,
`DESCRIPTION`,`MIN_RIDE_HEIGHT`,`MANUFACTURER`,`TOP_SPEED(MPH)`,`TRACK_LENGTH(FT)`,`ADDITIONAL_FEES`) 
SELECT RIDE_ID,`RIDE_NAME` ,`TYPE_OF_RIDE` ,`CAPACITY_OF_A_RIDE`,`RIDE_HEIGHT`,`YEARS_STARTED` ,
`DESCRIPTION`,`MIN_RIDE_HEIGHT`,`MANUFACTURER`,`TOP_SPEED(MPH)`,`TRACK_LENGTH(FT)`,`ADDITIONAL_FEES`
FROM ride2;


/*below are the 10 complex queries without external data*/

/* 1. */
select temp.C_ID, customer_with_age.EMAIL, customer_with_age.age
from (
select *
from(
select count(ticket.TICKET_ID) AS Number_of_invest, customer_with_age.C_ID
from ticket
inner join payment 
on ticket.PAYMENT_ID = payment.PAYMENT_ID
inner join ticket_category 
on ticket.CATEGORY_OF_TICKET_ID = ticket_category.CATEGORY_OF_TICKET_ID 
inner join (
SELECT *, YEAR(CURDATE()) - YEAR(DOB) AS age FROM customer
) as customer_with_age 
on ticket.C_ID = customer_with_age.C_ID
where payment.PROMO_APPLIED = 0 AND ticket.CATEGORY_OF_TICKET_ID = 1
group by customer_with_age.C_ID
ORDER BY count(ticket.TICKET_ID) DESC


) as a
where a.Number_of_invest = (select MAX(Number_of_invest) from (
select count(ticket.TICKET_ID) AS Number_of_invest, customer_with_age.C_ID
from ticket
inner join payment 
on ticket.PAYMENT_ID = payment.PAYMENT_ID
inner join ticket_category 
on ticket.CATEGORY_OF_TICKET_ID = ticket_category.CATEGORY_OF_TICKET_ID 
inner join (
SELECT *, YEAR(CURDATE()) - YEAR(DOB) AS age FROM customer
) as customer_with_age 
on ticket.C_ID = customer_with_age.C_ID
where payment.PROMO_APPLIED = 0 AND ticket.CATEGORY_OF_TICKET_ID = 1
group by customer_with_age.C_ID
ORDER BY count(ticket.TICKET_ID) DESC
)as b
)
)as temp
inner join customer on temp.C_ID = customer.C_ID
inner join (
SELECT *, YEAR(CURDATE()) - YEAR(DOB) AS age FROM customer
) as customer_with_age 
on temp.C_ID = customer_with_age.C_ID;



/* 2. */
select a.C_ID, SUM(a.PRICE) AS TOTAL_SPENT
from(
select TICKET.C_ID, PAYMENT.PRICE
from ticket 
inner join payment on ticket.PAYMENT_ID = payment.PAYMENT_ID
)as a
group by a.C_ID
order by SUM(a.PRICE) DESC
LIMIT 10;

/*3. */
select DISTINCT b.FACILITY_TYPE, b.max_visit, c.FACILITY_SUBTYPE
from(
select MAX(Number_of_visit) as max_visit, a.FACILITY_TYPE
from (
select facility.FACILITY_TYPE, facility.FACILITY_SUBTYPE, subtype_visit.Number_of_visit from facility
inner join(
select facility.FACILITY_SUBTYPE, SUM(FACILITY_TICKET_ID) AS Number_of_visit
from facility
inner join ticket_facility on facility.FACILITY_ID = ticket_facility.FACILITY_ID
group by facility.FACILITY_SUBTYPE

)as subtype_visit
on facility.FACILITY_SUBTYPE = subtype_visit.FACILITY_SUBTYPE
)as a
group by a.FACILITY_TYPE
)as b
inner join (
select facility.FACILITY_TYPE, facility.FACILITY_SUBTYPE, subtype_visit.Number_of_visit from facility
inner join(
select facility.FACILITY_SUBTYPE, SUM(FACILITY_TICKET_ID) AS Number_of_visit
from facility
inner join ticket_facility on facility.FACILITY_ID = ticket_facility.FACILITY_ID
group by facility.FACILITY_SUBTYPE

)as subtype_visit
on facility.FACILITY_SUBTYPE = subtype_visit.FACILITY_SUBTYPE
)as c
on b.max_visit= c.Number_of_visit;

/*4.*/
SELECT SUM(b.PRICE)as PROFIT, b.FACILITY_ID, b.FACILITY_DESC
FROM (
select a.FACILITY_ID, a.FACILITY_DESC, a.FACILITY_TICKET_ID AS PER_ENTRANCE, PAYMENT.PRICE
from ticket
inner join(
select facility.FACILITY_DESC, ticket_facility.FACILITY_ID, ticket_facility.TICKET_ID , TICKET_FACILITY.FACILITY_TICKET_ID from facility
inner join ticket_facility on facility.FACILITY_ID = ticket_facility.FACILITY_ID
)as a
on a.TICKET_ID = ticket.TICKET_ID
INNER JOIN PAYMENT ON TICKET.PAYMENT_ID = PAYMENT.PAYMENT_ID
)AS b
GROUP BY b.FACILITY_ID
order  by PROFIT DESC
LIMIT 10;

/*5.*/
SELECT c.TOTAL_VISIT, RIDE.RIDE_ID, RIDE.TYPE_OF_RIDE, RIDE.DESCRIPTION
FROM (
SELECT COUNT(VISIT_ID) AS TOTAL_VISIT, RIDE_ID
FROM(
SELECT a.RIDE_ID, a.TYPE_OF_RIDE, a.DESCRIPTION, TICKET.C_ID, CUSTOMER.GENDER, a.RIDE_TICKET_ID AS VISIT_ID
FROM TICKET 
INNER JOIN (
SELECT RIDE.RIDE_ID, RIDE.TYPE_OF_RIDE, RIDE.DESCRIPTION, TICKET_RIDE.TICKET_ID, TICKET_RIDE.RIDE_TICKET_ID FROM RIDE 
INNER JOIN TICKET_RIDE
ON RIDE.RIDE_ID = ticket_ride.RIDE_ID
)AS a
ON TICKET.TICKET_ID = a.TICKET_ID
inner join customer
on TICKET.C_ID = CUSTOMER.C_ID
WHERE CUSTOMER.GENDER = 'Female'
)AS b
GROUP BY b.RIDE_ID
)AS c
INNER JOIN RIDE 
ON c.RIDE_ID = RIDE.RIDE_ID
ORDER BY TOTAL_VISIT DESC
LIMIT 3;

/*6.*/
select count(RIDE_TICKET_ID) as NumberOfLikesFromOld, TYPE_OF_RIDE FROM(
select b.RIDE_TICKET_ID, b.TYPE_OF_RIDE, YEAR(CURDATE()) - YEAR(DOB) AS age  from (
select customer.DOB, a.RIDE_TICKET_ID, a.TYPE_OF_RIDE from ticket
inner join (
select ticket_ride.TICKET_ID, ticket_ride.RIDE_TICKET_ID, ride.TYPE_OF_RIDE from ride 
inner join ticket_ride
on ride.RIDE_ID = ticket_ride.RIDE_ID
) as a 
on ticket.TICKET_ID = a.TICKET_ID
inner join customer on ticket.C_ID = customer.C_ID
)as b
where YEAR(CURDATE()) - YEAR(DOB) > 50
) as C
group by TYPE_OF_RIDE
ORDER BY NumberOfLikesFromOld DESC
limit 1;

/*7.*/
select count(PAYMENT_ID) as NumberOfPayments, PAYMENT_METHOD_DESC FROM (
select b.PAYMENT_ID, b.PAYMENT_METHOD_DESC, b.PURCHASE_MODE,  YEAR(CURDATE()) - YEAR(DOB) AS age  
from (
select a.PAYMENT_ID,a.PAYMENT_METHOD_DESC, a.PURCHASE_MODE, customer.DOB from ticket
inner join (
select payment.PAYMENT_ID, payment.PAYMENT_METHOD_ID, payment_method.PAYMENT_METHOD_DESC,payment.PURCHASE_MODE from payment_method
inner join payment on payment_method.PAYMENT_METHOD_ID = payment.PAYMENT_METHOD_ID
)as a
on ticket.PAYMENT_ID = a.PAYMENT_ID
inner join customer on ticket.C_ID = customer.C_ID
) as b
where  YEAR(CURDATE()) - YEAR(DOB) > 50
) AS c
group by PAYMENT_METHOD_DESC
ORDER BY NumberOfPayments DESC;

select count(PAYMENT_ID) as NumberOfPayments, PURCHASE_MODE FROM (
select b.PAYMENT_ID, b.PAYMENT_METHOD_DESC, b.PURCHASE_MODE,  YEAR(CURDATE()) - YEAR(DOB) AS age  
from (
select a.PAYMENT_ID,a.PAYMENT_METHOD_DESC, a.PURCHASE_MODE, customer.DOB from ticket
inner join (
select payment.PAYMENT_ID, payment.PAYMENT_METHOD_ID, payment_method.PAYMENT_METHOD_DESC,payment.PURCHASE_MODE from payment_method
inner join payment on payment_method.PAYMENT_METHOD_ID = payment.PAYMENT_METHOD_ID
)as a
on ticket.PAYMENT_ID = a.PAYMENT_ID
inner join customer on ticket.C_ID = customer.C_ID
) as b
where  YEAR(CURDATE()) - YEAR(DOB) > 50
) AS c
group by PURCHASE_MODE
ORDER BY NumberOfPayments desc;

/*8.*/
select MIN(age), MAX(age) from (
select YEAR(CURDATE()) - YEAR(DOB) AS age  , PURCHASE_MODE from (
select payment.PURCHASE_MODE, customer.DOB from ticket
inner join payment on ticket.PAYMENT_ID = payment.PAYMENT_ID
inner join customer on ticket.C_ID = customer.C_ID
WHERE PURCHASE_MODE = 'Online'
) as a
) as b;


/*9.*/
select count(RIDE_TICKET_ID) AS NumberOfVisit, RIDE_NAME from (
select ride.RIDE_NAME, ticket_ride.RIDE_TICKET_ID, ticket_ride.TIMESTAMP
from ride
inner join ticket_ride on ride.RIDE_ID = ticket_ride.RIDE_ID
where year(TIMESTAMP) = '2019'
) as a
group by RIDE_NAME
ORDER BY NumberOfVisit DESC
limit 1;


/*10.*/
select count(a.FACILITY_TICKET_ID) as NumberOFVisits11To2 from 
(
select facility.FACILITY_TYPE, ticket_facility.FACILITY_TICKET_ID, ticket_facility.TIMESTAMP from ticket_facility
inner join facility on ticket_facility.FACILITY_ID = facility.FACILITY_ID
where facility.FACILITY_TYPE = 'Dinning'
)as a
where TIME(TIMESTAMP) >= "11:00:00"
AND TIME(TIMESTAMP) < "14:00:00"
AND YEAR(TIMESTAMP) = 2019;

select count(a.FACILITY_TICKET_ID) as NumberOFVisits2To5 from 
(
select facility.FACILITY_TYPE, ticket_facility.FACILITY_TICKET_ID, ticket_facility.TIMESTAMP from ticket_facility
inner join facility on ticket_facility.FACILITY_ID = facility.FACILITY_ID
where facility.FACILITY_TYPE = 'Dinning'
)as a
where TIME(TIMESTAMP) >= "14:00:00"
AND TIME(TIMESTAMP) < "17:00:00"
AND YEAR(TIMESTAMP) = 2019;

