-module(user_default).
-compile(export_all).
-include_lib("zql_all_imports.hrl").


zhelp() -> 
p("-----------------------------------------------------------------------------"),
p("-                                                                           -"),
p("-               default commands from the erlang shell                      -"),
p("-                                                                           -"),
p("-----------------------------------------------------------------------------"),
p("                                                                             "),
p(" shell( )                                  starts a ZQL shell                "),
p(" test ()                                   run the self tests for zql        "),
p(" test_connection( ConnectionArgs )         tests a connection                "),
p(" oo( )                                     returns an OO session to ZQL      "),
p(" c( )                                      compile all                       "),
p(" compile_all( )                            compile all                       "),
p("                                                                             "),
p(" Example:                                                                    "),
q(' C = [ {driver,db_cassandra_driver}, {hostname,"127.0.0.1"}].                '),
q(' test_connection( C).                                                        '),
q(' DB = oo( ).                                                                 '),
q(' Record = DB:get("key234").                                                  '),
p("-----------------------------------------------------------------------------"),
ok.

           
c() -> compile_all().  
compile_all() -> zql_compiler:compile_all().



sh() -> shell().
shell() -> zql_compiler:compile_all(),
           p(" start( )                                  starts mnesia database            "),
           zql_shell:init(),
           zql_shell:start().

test() -> zql:test().

oo() -> Session = zql_oo_helper:create_oo_session( sys_connection() ),
        Session.

mnesia() -> zql:get_connection(local_mnesia_connection).

init() -> zql_shell:init().

gpn(Key)->zql:get_property_names(mnesia(),Key).
set(Key,PropName,Value)->zql:set_property(mnesia(),Key,PropName,Value).