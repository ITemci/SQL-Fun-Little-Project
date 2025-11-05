-- Keep a log of any SQL queries you execute as you solve the mystery.
-- checking crimes on the day and month when our crime was commited, and on street we know
select description from crime_scene_reports
where day = 28 and month = 7 and street = 'Humphrey Street';
-- this gives us time that crime was commited: 10:15am at bakery.
-- there were interview with 3 witnesses mentioning bakery

-- accessing interviews table for the same day.
select name,transcript from interviews where day = 28 and month = 7 and transcript like '%bakery%';
-- this hints at cheking ATM machine in morning as thief was withdrawing money on leggett street ....DONE
-- CCTV from bakery for a car REG withing 10 minutes of crime ......DONE
-- check earliest flight out of town next day ....... DONE
-- check calls   ........DONE

-- check flights for earliest on 29th
select id, origin_airport_id, destination_airport_id from flights where day = 29 and month = 7 order by hour limit 1;
-- we get origin airport id = 8, destination airport id = 4, and flight ID = 36
-- now to find the destination city
select id,city from airports where id in(4,8);
-- this gives us the flight destination being New York City  .......... DONE

-- CCTV for car REG
select hour,minute,activity,license_plate from bakery_security_logs where day = 28 and month = 7 and year = 2023 and hour = 10 and minute > 15 and minute <=25;
-- this gave us a list of few vehicles reg that left

-- ATM databse
select account_number,atm_location,amount from atm_transactions where day = 28 and month = 7 and year = 2023 and transaction_type = 'withdraw' and atm_location = 'Leggett Street';
-- cross check for all accounts numbers holders names

-- checking phone calls less than a minute in the morgning between minute > 15 and minute < 25
select caller,receiver, duration from phone_calls  where day = 28 and month = 7 and year = 2023 and duration < 60;
-- this gives us a list of number callers and receivers with talk duration less than 60 sec. caller is thief, receiver is complice




-- cross check atm activity with bank accounts and people to get people id and passport numbers of people from ATM
create view atm_id_passport as select people.id, name , passport_number from people join bank_accounts on people.id = bank_accounts.person_id join atm_transactions on bank_accounts.account_number = atm_transactions.account_number where day = 28 and month = 7 and year = 2023 and transaction_type = 'withdraw' and atm_location = 'Leggett Street';

-- get id of people from car park
create view car_park as select people.id from people join bakery_security_logs on people.license_plate = bakery_security_logs.license_plate where day = 28 and month = 7 and year = 2023 and hour = 10 and minute > 15 and minute <=25;


-- phone calls caller id
 create view caller_id as select people.id from people join phone_calls on people.phone_number = phone_calls.caller  where day = 28 and month = 7 and year = 2023 and duration < 60;

-- phone calls receiver
create view receiver_id as select people.id, passport_number from people join phone_calls on people.phone_number = phone_calls.receiver  where day = 28 and month = 7 and year = 2023 and duration < 60;


-- passengers of flight nr 36 combined with phone calls
create view flight_passports as select passport_number from passengers where flight_id = 36;

-- combining all views to find the thief
select * from atm_id_passport inner join flight_passports on atm_id_passport.passport_number = flight_passports.passport_number
inner join caller_id on atm_id_passport.id = caller_id.id
inner join car_park on atm_id_passport.id = car_park.id;
-- this gives us 1 result. Bruce was the thief as he was in the caller database, as well as he left the car park at the time matching the witness timing,
-- as well as he was in ATM database withdrawing money in the morning, and he was on the earliest flight out of city next day.

-- finding his accomplice
select receiver from phone_calls where caller = (select phone_number from people where name = 'Bruce') and day = 28 and month = 7 and year = 2023 and duration < 60 ;
-- this gives us the number of person who Bruce called that morning at the specific time.
select name from people where phone_number = '(375) 555-8161';
-- now we have the accomplice name which is Robin.

CASE SOLVED !!!
