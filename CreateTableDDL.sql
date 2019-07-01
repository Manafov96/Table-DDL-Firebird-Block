execute block (
  TABLE_IN varchar(25) =: TABLE_NAME
)
returns (
  STMT varchar(8000)
)
as
declare variable CRLF varchar(30);
declare variable TABLE_NAME varchar(25);
declare variable COLUMS varchar(50);
declare variable FLAG smallint;
declare variable FIELD_SOURCE varchar(50);
begin
  STMT = '';
  CRLF = ascii_char(13) || ascii_char(10);
  select
    TABLE_NAME
  from
  (
    select -- select list of table name
      RDB$RELATION_NAME as TABLE_NAME
    from
      RDB$RELATIONS
    where
      RDB$VIEW_BLR is null and (RDB$SYSTEM_FLAG is null or RDB$SYSTEM_FLAG = 0)
  )
  where
    TABLE_NAME = :TABLE_IN
  into
    :TABLE_NAME;
   if(TABLE_NAME is null) then
     exit;
   else
     begin
       for select -- select colums list, null_flag and domain
         RDB$FIELD_NAME, RDB$FIELD_SOURCE, RDB$NULL_FLAG
        from
          RDB$RELATION_FIELDS
        where
          RDB$RELATION_NAME is not distinct from :TABLE_IN
        into
          :COLUMS, :FIELD_SOURCE, :FLAG
        do
        begin
          STMT = STMT || trim(COLUMS) || ' ' || trim(FIELD_SOURCE)|| ''||
          iif(FLAG = 1, ' not null', trim(' ')) || ',' || CRLF;
        end
       end
       STMT = 'CREATE TABLE ' || trim(TABLE_NAME) || ' (' || CRLF ||
              substring(STMT from 1 for (char_length(STMT) - 3)) || CRLF || ')' ||';' ;
  suspend;
end
