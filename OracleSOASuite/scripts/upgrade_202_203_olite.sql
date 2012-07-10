drop table id_range;

create table id_range
(
   range_name      varchar2( 50 )  not null,
   next_range      integer         not null,
   dummy_col       varchar2( 1 )   null
);
insert into id_range( range_name, next_range ) values( 'cikey', 1 );
insert into id_range( range_name, next_range ) values( 'namespace', 1 );
commit;

update version_server set guid = '2.0.3';
commit;

update id_range set next_range = ( select nvl(max( cikey ) + 1, 1) from cube_instance) where range_name = 'cikey';
update id_range set next_range = ( select max( namespace_id ) + 1 from namespace ) where range_name = 'namespace';
commit;