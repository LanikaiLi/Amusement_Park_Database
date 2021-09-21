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




CREATE TABLE COVID19_DATA(
`date` DATE,
`CUMULATIVE_UNIQUE_PEOPLE_TESTED` INT,
`CUMULATIVE_UNIQUE_PEOPLE_TESTED_POSITIVE` INT,
`CUMULATIVE_UNIQUE_PEOPLE_TESTED_NEGATIVE` INT,
`UNIQUE_PEOPLE_TESTED` INT,
`UNIQUE_PEOPLE_TESTED_POSITIVE` INT,
`UNIQUE_PEOPLE_TESTED_NEGATIVE` INT,
`UNIQUE_PEOPLE_TESTED_POSITIVITY_PERCENT` DOUBLE,
`SAMPLES_ANALYZED` INT,
 `CUMULATIVE_SAMPLES_ANALYZED` INT,
PRIMARY KEY (`DATE`)
);

CREATE TABLE TICKET_RIDE(
RIDE_TICKET_ID INT NOT NULL,
RIDE_ID VARCHAR(100),
TICKET_ID INT,
TIMESTAMP DATETIME,
`date` DATE,
PRIMARY KEY (RIDE_TICKET_ID),
FOREIGN KEY (TICKET_ID) REFERENCES TICKET(TICKET_ID),
FOREIGN KEY (RIDE_ID) REFERENCES RIDE(RIDE_ID),
FOREIGN KEY (`date`) REFERENCES COVID19_DATA(`date`)
); 

CREATE TABLE TICKET_FACILITY(
FACILITY_TICKET_ID INT NOT NULL,
TICKET_ID INT,
FACILITY_ID VARCHAR(100),
TIMESTAMP DATETIME,
`date` DATE,
PRIMARY KEY (FACILITY_TICKET_ID),
FOREIGN KEY (TICKET_ID) REFERENCES TICKET(TICKET_ID),
FOREIGN KEY (FACILITY_ID) REFERENCES FACILITY(FACILITY_ID),
FOREIGN KEY (`date`) REFERENCES COVID19_DATA(`date`)
); 



/*the following is the query to manipulate Covid19_data table*/
/* I first use python to upload covid data to covid19_data_2 table, 
then use sql to insert covid19_data from covid19_data_2*/
/*I will also submit all python files I used*/


INSERT INTO 
RIDE (RIDE_ID,`RIDE_NAME`,`TYPE_OF_RIDE`,`CAPACITY_OF_A_RIDE`,`RIDE_HEIGHT`,`YEARS_STARTED`,
`DESCRIPTION`,`MIN_RIDE_HEIGHT`,`MANUFACTURER`,`TOP_SPEED(MPH)`,`TRACK_LENGTH(FT)`,`ADDITIONAL_FEES`) 
SELECT RIDE_ID,`RIDE_NAME` ,`TYPE_OF_RIDE` ,`CAPACITY_OF_A_RIDE`,`RIDE_HEIGHT`,`YEARS_STARTED` ,
`DESCRIPTION`,`MIN_RIDE_HEIGHT`,`MANUFACTURER`,`TOP_SPEED(MPH)`,`TRACK_LENGTH(FT)`,`ADDITIONAL_FEES`
FROM la_ronde_amusement_park.ride2;

INSERT INTO 
covid19_data (`date`,`cumulative_unique_people_tested`,`cumulative_unique_people_tested_positive`,`cumulative_unique_people_tested_negative`,`unique_people_tested`,`unique_people_tested_positive`,`unique_people_tested_negative`,`unique_people_tested_positivity_percent`,`samples_analyzed`,`cumulative_samples_analyzed`) 
SELECT `date`,`cumulative_unique_people_tested`,`cumulative_unique_people_tested_positive`,`cumulative_unique_people_tested_negative`,`unique_people_tested`,`unique_people_tested_positive`,`unique_people_tested_negative`,`unique_people_tested_positivity_percent`,`samples_analyzed`,`cumulative_samples_analyzed`
FROM covid19_data_2;


/*below are the 5 complex queries using the external data*/

/*1*/
select x.TotalVisitToDinning, x.perMonth, y.cumulative_positive_cases from (
select sum(FACILITY_TICKET_ID) as TotalVisitToDinning, month(date) as perMonth from(
select ticket_facility.date, facility.FACILITY_TYPE, ticket_facility.FACILITY_TICKET_ID from ticket_facility
inner join facility on ticket_facility.FACILITY_ID = facility.FACILITY_ID
where facility.FACILITY_TYPE = 'Dinning'
) as a
group by month(date)
) as x
inner join (
select max(cumulative_unique_people_tested_positive) as cumulative_positive_cases, month(date) as perMonth
 from covid19_data
 group by month(date)
)as y
on x.perMonth = y.perMonth;

/*2*/
select x.perMonth, y.totalVisitOfOld, x.Cumulative_people_tested_positive from (
select max(CUMULATIVE_UNIQUE_PEOPLE_TESTED_POSITIVE) AS Cumulative_people_tested_positive , MONTH(date) as perMonth
from covid19_data
group by month(date)
) as x
inner join (
select (visitsToFacility + visitsToRide) as totalVisitOfOld, `month(date)` as perMonth from(
 select sum(FACILITY_TICKET_ID) as visitsToFacility, sum(RIDE_TICKET_ID) as visitsToRide, month(date) from (
select a.FACILITY_TICKET_ID, a.date, a.RIDE_TICKET_ID, year(current_date())-year(a.DOB) as age, covid19_data.CUMULATIVE_UNIQUE_PEOPLE_TESTED_POSITIVE from (
select ticket_facility.FACILITY_TICKET_ID, ticket_facility.date, ticket_ride.RIDE_TICKET_ID, customer.DOB from ticket inner join ticket_facility on ticket.TICKET_ID = ticket_facility.TICKET_ID inner join ticket_ride on ticket_ride.TICKET_ID = ticket.TICKET_ID inner join customer on ticket.C_ID = customer.C_ID) as a
inner join covid19_data on a.date = covid19_data.date
where (year(current_date())-year(DOB)) > 50
) as b
group by month(date)
) as c
)as y
on x.perMonth = y.perMonth;

/*3*/
select RIDE.RIDE_ID, RIDE.RIDE_NAME, RIDE.TYPE_OF_RIDE from (
select SUM(RIDE_TICKET_ID) as Number_Visit_During_CovidPeak, RIDE_ID
from (
select ridesInWorst.date, ride.RIDE_ID, ride.RIDE_NAME, ride.TYPE_OF_RIDE, ridesInWorst.RIDE_TICKET_ID from (
select * from ticket_ride
where month(date) = ( 
select worstPeriod from (
select b.most_cases, c.perMonth as worstPeriod from (
select max(cumulative_positive_cases) as most_cases from (
select max(cumulative_unique_people_tested_positive) as cumulative_positive_cases, month(date) as perMonth
 from covid19_data
 where month(date)<'9'
 group by month(date)
 ) as a
 ) as b
 inner join (
 select max(cumulative_unique_people_tested_positive) as cumulative_positive_cases, month(date) as perMonth
 from covid19_data
 group by month(date)
 )as c 
 on b.most_cases = c.cumulative_positive_cases
)as worstmonth
 )
) as ridesInWorst
inner join ride 
on ridesInWorst.RIDE_ID = RIDE.RIDE_ID
)as R
group by R.RIDE_ID
order by Number_Visit_During_CovidPeak DESC
limit 3
) as N
inner join ride on N.RIDE_ID = RIDE.RIDE_ID;


/*4*/
select (NumberSoldInApril - NumberSoldInJan) as IncreaseFromJanToApril, Jan.CATEGORY_OF_TICKET_DESC from (
SELECT COUNT(TICKET_ID) NumberSoldInApril, CATEGORY_OF_TICKET_DESC FROM (
SELECT * FROM (
SELECT C.CATEGORY_OF_TICKET_ID, C.MONTH, C.CUMULATIVE_UNIQUE_PEOPLE_TESTED_POSITIVE, TICKET_CATEGORY.CATEGORY_OF_TICKET_DESC , C.TICKET_ID FROM (
SELECT A. TICKET_ID, A.CATEGORY_OF_TICKET_ID, A.MONTH, B.CUMULATIVE_UNIQUE_PEOPLE_TESTED_POSITIVE FROM (
select TICKET_ID, CATEGORY_OF_TICKET_ID, MONTH(PURCHASE_DATE) AS MONTH
FROM TICKET
)AS A
INNER JOIN (
SELECT CUMULATIVE_UNIQUE_PEOPLE_TESTED_POSITIVE, MONTH(DATE) AS MONTH
FROM covid19_data
)AS B
ON A.MONTH = B.MONTH
) AS C
INNER JOIN ticket_category ON C.CATEGORY_OF_TICKET_ID = ticket_category.CATEGORY_OF_TICKET_ID
)AS D
 WHERE MONTH = '4'
 ) AS E
 GROUP BY CATEGORY_OF_TICKET_DESC
 ORDER BY NumberSoldInApril DESC
)as April
inner join (
SELECT COUNT(TICKET_ID) NumberSoldInJan, CATEGORY_OF_TICKET_DESC FROM (
SELECT * FROM (
SELECT C.CATEGORY_OF_TICKET_ID, C.MONTH, C.CUMULATIVE_UNIQUE_PEOPLE_TESTED_POSITIVE, TICKET_CATEGORY.CATEGORY_OF_TICKET_DESC , C.TICKET_ID FROM (
SELECT A. TICKET_ID, A.CATEGORY_OF_TICKET_ID, A.MONTH, B.CUMULATIVE_UNIQUE_PEOPLE_TESTED_POSITIVE FROM (
select TICKET_ID, CATEGORY_OF_TICKET_ID, MONTH(PURCHASE_DATE) AS MONTH
FROM TICKET
)AS A
INNER JOIN (
SELECT CUMULATIVE_UNIQUE_PEOPLE_TESTED_POSITIVE, MONTH(DATE) AS MONTH
FROM covid19_data
)AS B
ON A.MONTH = B.MONTH
) AS C
INNER JOIN ticket_category ON C.CATEGORY_OF_TICKET_ID = ticket_category.CATEGORY_OF_TICKET_ID
)AS D
 WHERE MONTH = '1'
 ) AS E
 GROUP BY CATEGORY_OF_TICKET_DESC
 ORDER BY NumberSoldInJan DESC
)as Jan
on April.CATEGORY_OF_TICKET_DESC = Jan.CATEGORY_OF_TICKET_DESC;


/*5*/
select count(PAYMENT_ID) AS NumberOfPayments, PURCHASE_MODE from (
select ticket.PAYMENT_ID, ticket.purchase_date, payment.purchase_mode from ticket
inner join payment on ticket.PAYMENT_ID = payment.PAYMENT_ID
where month (purchase_date) = (
select worstPeriod from (
select b.most_cases, c.perMonth as worstPeriod from (
select max(cumulative_positive_cases) as most_cases from (
select max(cumulative_unique_people_tested_positive) as cumulative_positive_cases, month(date) as perMonth
 from covid19_data
 where month(date)<'9' 
 group by month(date)
 ) as a
 ) as b
 inner join (
 select max(cumulative_unique_people_tested_positive) as cumulative_positive_cases, month(date) as perMonth
 from covid19_data
 group by month(date)
 )as c 
 on b.most_cases = c.cumulative_positive_cases
)as worstmonth
)
)as O
group by purchase_mode
order by NumberOfPayments DESC;
