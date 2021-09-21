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
