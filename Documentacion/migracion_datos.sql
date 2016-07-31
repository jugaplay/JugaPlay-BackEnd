

INSERT INTO 
channels(
user_id, mail, sms, 
whatsapp, push, created_at, updated_at)

SELECT 

 id,

 CASE WHEN (users.email is not null)
 THEN true
 ELSE false
 END AS mail,

 CASE WHEN (users.telephone is not null)
 THEN true
 ELSE false
 END AS sms,

 CASE WHEN (users.telephone is not null)
 THEN true
 ELSE false
 END AS whatsapp,

 CASE WHEN (users.push_token is not null)
 THEN true
 ELSE false
 END AS push ,

 Now(),
 Now()

 FROM users 
;


INSERT INTO notification_types (
name, created_at, updated_at)
values('result',
now(),
now())
;


INSERT INTO notification_types (
name, created_at, updated_at)
values('challenge',
now(),
now())
;

INSERT INTO notification_types (
name, created_at, updated_at)
values('news',
now(),
now())
;


INSERT INTO notification_types (
name, created_at, updated_at)
values('personal',
now(),
now())
;


INSERT INTO languages(
            name, created_at, updated_at)
    VALUES ('Spanish', now(), now());

INSERT INTO languages(
            name, created_at, updated_at)
    VALUES ('English', now(), now());

INSERT INTO languages(
            name, created_at, updated_at)
    VALUES ('Portuguese', now(), now());




INSERT INTO countries(
            name, language_id, created_at, updated_at)
     SELECT 'Argentina', ID , now(), now() FROM languages where name = 'Spanish' ;


INSERT INTO countries(
            name, language_id, created_at, updated_at)
     SELECT 'Brazil', ID , now(), now() FROM languages where name = 'Portuguese' ;


INSERT INTO countries(
            name, language_id, created_at, updated_at)
     SELECT 'Uruguay', ID , now(), now() FROM languages where name = 'Spanish' ;

INSERT INTO countries(
            name, language_id, created_at, updated_at)
     SELECT 'Paraguay', ID , now(), now() FROM languages where name = 'Spanish' ;

INSERT INTO countries(
            name, language_id, created_at, updated_at)
     SELECT 'Colombia', ID , now(), now() FROM languages where name = 'Spanish' ;

INSERT INTO countries(
            name, language_id, created_at, updated_at)
     SELECT 'España', ID , now(), now() FROM languages where name = 'Spanish' ;

INSERT INTO countries(
            name, language_id, created_at, updated_at)
     SELECT 'Ecuador', ID , now(), now() FROM languages where name = 'Spanish' ;

INSERT INTO countries(
            name, language_id, created_at, updated_at)
     SELECT 'Chile', ID , now(), now() FROM languages where name = 'Spanish' ;    

INSERT INTO countries(
            name, language_id, created_at, updated_at)
     SELECT 'Perú', ID , now(), now() FROM languages where name = 'Spanish' ;    

INSERT INTO countries(
            name, language_id, created_at, updated_at)
     SELECT 'Venezuela', ID , now(), now() FROM languages where name = 'Spanish' ;    


alter table players alter column description SET  default '';





INSERT INTO
t_prizes  (coins, user_id, detail, prize_id, created_at, updated_at)

SELECT 
coins as coins, 
user_id as user_id, 
'Premio en mesa: '|| title as detail,
prize_id as prize_id,
Now(),
Now()

FROM 
(select prizes.id as prize_id, coins, position, table_id from prizes
inner join tables 
on tables.id = prizes.table_id
) prizes

INNER JOIN 

(
select table_id, user_id, position from table_winners where table_id in 
(
select distinct table_id from prizes
inner join tables as t
on table_id = prizes.table_id
)
) winners

ON (winners.table_id  = prizes.table_id AND winners.position  = prizes.position)

INNER JOIN tables
ON tables.id = winners.table_id 
