-- Drop Tables if exists.
drop table IF exists db_lock;
drop function IF exists getNextSeq(text, integer, integer);
drop table IF exists APP_SEQ;


create table db_lock (
    id SERIAL primary key,
    name varchar(50) not null,
    created_dt TIMESTAMPTZ default now()
);

create table APP_SEQ (
    id SERIAL primary key,
    user_id integer not null,
    last_seq integer not null,
    unique (user_id)
);

CREATE OR REPLACE FUNCTION getNextSeq(prefix text, uid integer, sleep_time integer) RETURNS text AS '
declare
l_seq integer;
new_seq integer;
BEGIN
insert into APP_SEQ(user_id, last_seq) select uid, 0 where not exists (select user_id, last_seq from APP_SEQ t where t.user_id = uid);
select last_seq into l_seq from APP_SEQ where user_id=uid for update;
new_seq = l_seq + 1;
PERFORM pg_sleep(sleep_time);
update APP_SEQ set last_seq = new_seq where user_id=uid;
return format(''%s-%s'',prefix, lpad(new_seq::text, 7, ''0''));
END; '
LANGUAGE PLPGSQL;



insert into db_lock(name) values ('sach1-aaaa');
insert into db_lock(name) values ('sach1-bbbb');
insert into db_lock(name) values ('sach1-cccc');

insert into APP_SEQ (user_id, last_seq) values (1, 100);