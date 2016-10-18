

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

alter table players alter column description SET  default '';

INSERT INTO t_prizes  (coins, user_id, detail, prize_id, created_at, updated_at)

SELECT 
coins as coins, 
user_id as user_id, 
'Premio en : '|| title as detail,
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




INSERT INTO request_types(
            name, created_at, updated_at)
    VALUES ('Facebook', now(), now());


INSERT INTO request_types(
            name, created_at, updated_at)
    VALUES ('Whatsapp', now(), now());


INSERT INTO request_types(
            name, created_at, updated_at)
    VALUES ('SMS', now(), now());

INSERT INTO request_types(
            name, created_at, updated_at)
    VALUES ('Mail', now(), now());
    
INSERT INTO request_types(
            name, created_at, updated_at)
    VALUES ('Twitter', now(), now());

INSERT INTO request_types(
            name, created_at, updated_at)
    VALUES ('Link', now(), now());    



INSERT INTO invitation_statuses(
            name, created_at, updated_at)
    VALUES ('Unused', now(), now());


INSERT INTO invitation_statuses(
            name, created_at, updated_at)
    VALUES ('Entered', now(), now());


INSERT INTO invitation_statuses(
            name, created_at, updated_at)
    VALUES ('Registred', now(), now());


INSERT INTO notification_types(
             name, 
            created_at,
             updated_at)
    VALUES ('challenge', now(), now());

INSERT INTO notification_types(
             name, 
            created_at,
             updated_at)
    VALUES ('result', now(), now());

INSERT INTO notification_types(
             name, 
            created_at,
             updated_at)
    VALUES ('new', now(), now());


INSERT INTO notification_types(
             name, 
            created_at,
             updated_at)
    VALUES ('personal', now(), now());

INSERT INTO notification_types(
             name, 
            created_at,
             updated_at)
    VALUES ('exchange-ready', now(), now());

INSERT INTO notification_types(
             name, 
            created_at,
             updated_at)
    VALUES ('friend-invitation', now(), now());
            



