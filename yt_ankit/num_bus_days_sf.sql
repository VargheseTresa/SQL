/*

 find difference between 2 dates excluding weekends and public holidays .
 Basically we need to find business days between 2 given dates using SQL.

 */
use MOGO_DWH_DEV.BI_TRESAV;

create or replace table tickets
(
ticket_id varchar(10),
create_date date,
resolved_date date
);

insert into tickets values
(1,'2022-08-01','2022-08-03')
,(2,'2022-08-01','2022-08-12')
,(3,'2022-08-01','2022-08-16');
create table holidays
(
holiday_date date
,reason varchar(100)
);
delete from holidays;
insert into holidays values
('2022-08-11','Rakhi'),('2022-08-15','Independence day');

insert into holidays values
('2022-08-14','Onam');

/************************ DML
*/

select * from tickets;
select * from holidays;


select *,
    datediff(day, create_date, resolved_date) num_days,
    datediff(week, create_date, resolved_date) num_weeks
from tickets;

select holiday_date, dayofweek(holiday_date) from holidays;

with h as(
select ticket_id,
    datediff(day, create_date, resolved_date) num_days,
    datediff(week, create_date, resolved_date) num_weeks,
    count(holiday_date) num_holidays
from tickets
    left join holidays on holiday_date between create_date and resolved_date
        and dayofweek(holiday_date) not in (0, 7) -- exclude holidays on weekends
group by 1, 2, 3)
select
    *,
    num_days - (2 * num_weeks) - num_holidays as num_business_days
from h;