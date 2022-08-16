-- 

create database yt_ankit;
use yt_ankit;

create table tickets
(
ticket_id varchar(10),
create_date date,
resolved_date date
);
delete from tickets;
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

/*
 find difference between 2 dates excluding weekends and public holidays . 
 Basically we need to find business days between 2 given dates using SQL.  
 */
 
 select *, dayofweek(resolved_date) from tickets;
 
 with a as (
 select *, datediff(resolved_date, create_date) actual_diff,
	floor(datediff(resolved_date, create_date) / 7) num_weeks
 from tickets)
 select *,
	case when dayofweek(create_date) = 1 then actual_diff - (num_weeks * 2) - 1
		when dayofweek(create_date) = 7 then actual_diff - (num_weeks * 2) - 2
        else actual_diff - (num_weeks * 2) 
	end as op
 from a;
--  

select *
from tickets left join holidays
	on holiday_date between create_date and resolved_date;


select ticket_id, count(holiday_date)
from tickets left join holidays
	on holiday_date between create_date and resolved_date
group by ticket_id;


 with a as (
 select *, datediff(resolved_date, create_date) actual_diff,
	floor(datediff(resolved_date, create_date) / 7) num_weeks
 from tickets),
	holidays as (
    select ticket_id, count(holiday_date) num_holidays
	from tickets left join holidays
		on holiday_date between create_date and resolved_date
        and 
	group by ticket_id
    )
 select *,
	case when dayofweek(create_date) = 1 then actual_diff - (num_weeks * 2) - 1 - num_holidays
		when dayofweek(create_date) = 7 then actual_diff - (num_weeks * 2) - 2 - num_holidays
        else actual_diff - (num_weeks * 2) - num_holidays
	end as op
 from a inner join holidays h on a.ticket_id = h.ticket_id;
 
 -- Additional challenge
 -- Insert a holiday that is a weekend. 
 insert into holidays values
('2022-08-14','Onam');

select holiday_date, dayofweek(holiday_date) from holidays;

with a as (
 select *, datediff(resolved_date, create_date) actual_diff,
	floor(datediff(resolved_date, create_date) / 7) num_weeks
 from tickets),
	holidays as (
    select ticket_id, count(holiday_date) num_holidays
	from tickets left join holidays
		on holiday_date between create_date and resolved_date
        and dayofweek(holiday_date) not in (1, 7)
	group by ticket_id
    )
 select *,
	case when dayofweek(create_date) = 1 then actual_diff - (num_weeks * 2) - 1 - num_holidays
		when dayofweek(create_date) = 7 then actual_diff - (num_weeks * 2) - 2 - num_holidays
        else actual_diff - (num_weeks * 2) - num_holidays
	end as op
 from a inner join holidays h on a.ticket_id = h.ticket_id;
 
 -- assumption: create_date is never a weekend.
 
 select *,
	datediff(resolved_date, create_date) num_days,
    weekofyear(resolved_date) - weekofyear(create_date) num_weeks
 from tickets;
 
 select *,
	num_days - (num_weeks * 2) - num_holidays num_business_days
 from (
  select ticket_id, create_date, resolved_date,
	datediff(resolved_date, create_date) num_days, weekofyear(resolved_date) - weekofyear(create_date) num_weeks,
    count(holiday_date) num_holidays    
 from tickets left join holidays on holiday_date between create_date and resolved_date
	and dayofweek(holiday_date) not in (1, 7)
 group by 1, 2, 3, 4) A;