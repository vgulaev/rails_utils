require 'mysql2'

dbmane = 'mcommons_development'

conn = Mysql2::Client.new(:database => dbmane, :username => 'root' )

# res  = conn.query( "select *
# FROM information_schema.table_constraints
# where table_catalog = '#{dbmane}'
# and constraint_type = 'FOREIGN KEY'" )
res  = conn.query( "select *
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
where CONSTRAINT_TYPE = 'FOREIGN KEY'
and CONSTRAINT_SCHEMA = 'mcommons_development'" )

res.to_a.each { |e|
    tablename = e[ "TABLE_NAME" ]
    constraint_name = e[ "CONSTRAINT_NAME" ]
    sql = "ALTER TABLE #{tablename} DROP FOREIGN KEY #{constraint_name}"
    puts( e )
    conn.query( sql )
}

# res = conn.query( "SELECT cc.table_name, cc.column_name from INFORMATION_SCHEMA.COLUMNS cc
# left join (SELECT cu.table_name, cu.column_name
# from information_schema.key_column_usage cu
# join information_schema.table_constraints tc on cu.constraint_name = tc.constraint_name
# where constraint_type = 'PRIMARY KEY' ) pk on pk.table_name = cc.table_name and cc.column_name = pk.column_name
# where pk.table_name is null
# and cc.is_nullable = 'NO'
# and cc.table_schema = 'public'
# and cc.table_catalog = '#{dbmane}'" )

# res.to_a.each { |e|
#     table_name   = e[ "table_name" ]
#     column_name     = e[ "column_name" ]
#     sql = "ALTER TABLE #{table_name} ALTER #{column_name} DROP NOT NULL"
#     conn.query( sql )
#     puts( sql )
# }