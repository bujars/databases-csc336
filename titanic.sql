<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<!-- saved from url=(0055)http://www-users.cs.umn.edu/~jyoo/5708/lab4/titanic.sql -->
<HTML><HEAD>
<META http-equiv=Content-Type content="text/html; charset=windows-1252">
<META content="MSHTML 6.00.2800.1400" name=GENERATOR></HEAD>
<BODY><PRE>drop table titanic;
drop table class;
drop table age;
drop table gender;

create table class
(id number,
 category varchar2(7),
 primary key (id)
);

create table age
(id number,
 category varchar2(7),
 primary key (id)
);

create table gender
(id number,
 category varchar2(7),
 primary key(id)
);

insert into class
values( 0, 'crew');

insert into class
values( 1, 'first');

insert into class
values( 2, 'second');

insert into class
values( 3, 'third');

commit;

insert into age
values (0, 'child');

insert into age
values (1, 'adult');

commit;

insert into gender
values(0, 'female');

insert into gender
values(1, 'male');

commit;


create table titanic
(class number,
 age number,
 gender number,
 survived number,
 foreign key (class) references class(id),
 foreign key (age) references age(id),
 foreign key (gender) references gender(id)
);

insert into titanic
select * from s1g30.titanic;

commit;

</PRE></BODY></HTML>
