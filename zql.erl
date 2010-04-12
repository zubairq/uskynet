-module(zql).
-compile(export_all).
-import(zprint,[println/1,p/1,print_number/1]).
-import(zutils,[uuid/0]).

help() -> 
p("-----------------------------------------------------------------------------"),
p("-                                MODULE zql                                 -"),
p("-                   Erlang interface to the ZQL system                      -"),
p("-----------------------------------------------------------------------------"),
p("print(Connection, ID)                             print record with key ID"),
p("print_all(Connection)                             print all records"),
p("C = [{driver,db_riak_driver},{hostname,'riak@127.0.0.1'},{bucket,<<\"default\">>}],"),
p(""),
p("zql:set(C, \"boy\", \"Is here\"),"),
p("Value = zql:get(C, \"boy\")."),
p(""),
p(">> \"Is here\"\n\n"),
p("C = zql:local().                     -- gets a connection locally"),
p("zql:set(C, Key, Value ).             -- set a key / value"),
p("zql:get(C, Key).                     -- get a value"),
p("zql:exists(C, Key).                  -- true / false"),
p("zql:delete(C, Key).                  -- ok"),
p("zql:delete_all(C, yes_im_sure).      -- ok"),
p("zql:ls(C).                           -- get all keys as a list"),
p("R = zql:create(C).                   -- create a record and return it's unique ID"),
p("zql:print(C,R).                      -- prints the record in a screen friendly format"),
p("zql:set(C,R,type,person).            -- sets the type of the record to a person"),
p("-------------------------------------------------------------------------"),
ok.





help(Command)       ->  HelpFunctionName = atom_to_list(Command) ++ "_help",
                        apply(zql, list_to_atom(HelpFunctionName), []).









print_help() -> 
p("---------------------------------------------------------------------"),
p("-                    print(Connection, RecordID)                    -"),
p("-                                                                   -"),
p("-             Prints the record with ID of RecordID                 -"),
p("-                                                                   -"),
p("---------------------------------------------------------------------").

print(Connection, RecordId) -> 

    Record = get(Connection, RecordId),
    println("-------------------------"),
    io:format("ID:~s~n", [RecordId]),
    case is_list(Record) of
        true -> lists:foreach(
             fun({PropertyName,Value}) -> io:format("~s:~s~n", [PropertyName,Value]) end,Record);

        false -> io:format("~s~n", [Record])
    end,
    println("").






print_all_help()  -> 
p("---------------------------------------------------------------------"),
p("-                    print_all(Connection)                          -"),
p("-                                                                   -"),
p("-       Prints all the records to the console                       -"),
p("-                                                                   -"),
p("---------------------------------------------------------------------").

print_all(C) -> PrintRecord = fun(RecordId) -> print(C,RecordId) end,
                lists:foreach(PrintRecord, zql:ls(C)).




match_help() -> 
p("---------------------------------------------------------------------"),
p("-                    match(Connection)                              -"),
p("-                                                                   -"),
p("- This should match a set of records. Not implemented yet though    -"),
p("-                                                                   -"),
p("---------------------------------------------------------------------").

%match(RecordData,Queries) -> 
lists:foreach( fun(Property) -> match_property(Property,Queries) end , RecordData ).
%match_property(Property, Queries) -> lists:foreach( fun(Query) -> 
match(Value, equals, Value) -> true;
match(_Value, equals, _ExpectedValue) -> false.







connect_help() -> 
p("---------------------------------------------------------------------"),
p("-                    connect(ConnectionArgs)                        -"),
p("-                                                                   -"),
p("-          connects to the database and returns the connection      -"),
p("-                                                                   -"),
p("---------------------------------------------------------------------").

connect(ConnectionArgs) -> Driver =
                           proplists:get_value(driver,ConnectionArgs),
                           Driver.




get_help() -> 
p("---------------------------------------------------------------------"),
p("-                    get(Connection, Key)                           -"),
p("-                                                                   -"),
p("-           gets the value from the database for Key                -"),
p("-                                                                   -"),
p("---------------------------------------------------------------------").

get(Connection,Key) -> Driver = connect(Connection),
                       Value = apply(Driver, get, [Connection, Key]),
                       Value.







get_property_names_help() -> 
p("---------------------------------------------------------------------"),
p("-                 get_property_names(Connection,Key)                -"),
p("-                                                                   -"),
p("-     gets all the properties for the record identified by Key      -"),
p("-                                                                   -"),
p("---------------------------------------------------------------------").

get_property_names(Connection,Key) ->      Driver = connect(Connection),
                                           PropertyNames = apply(Driver, get_properties, [Connection, Key]),
                                           PropertyNames.






get_property_help() -> 
p("---------------------------------------------------------------------"),
p("-                 get_property(Connection,Key,PropertyName)         -"),
p("-                                                                   -"),
p("- gets the value of the named property for record identified by Key -"),
p("-                                                                   -"),
p("---------------------------------------------------------------------").

get_property(C,Key,PropertyName) -> Driver = connect(C),
                                    Data = get(C,Key),
                                    Value = [ {Prop,Value} || {Prop,Value} <- Data, Prop == PropertyName ],
                                    [{PN, V} | _] = Value,
                                    V.






set_help() -> 
p("---------------------------------------------------------------------"),
p("-                    set(Connection,Key,Value)                      -"),
p("-                                                                   -"),
p("-      sets the value for a record identified by Key                -"),
p("-                                                                   -"),
p("---------------------------------------------------------------------").

set(Connection,Key,Value) -> Driver = connect(Connection),
                             apply(Driver, set, [Connection, Key, Value]),                                  
                             ok.





create_help() -> 
p("---------------------------------------------------------------------"),
p("-                    create(Connection)                             -"),
p("-                                                                   -"),
p("-               I'm not really sure what this does                  -"),
p("-                                                                   -"),
p("---------------------------------------------------------------------").

create(Connection) -> Driver = connect(Connection),
                      Key = apply(Driver, create, [Connection]),
                      Key.








add_property_help() -> 
p("---------------------------------------------------------------------"),
p("-        add_propertty(Connection,Key,PropertyName,Value)           -"),
p("-                                                                   -"),
p("-   This adds a named property to a record identified by Key        -"),
p("-                                                                   -"),
p("---------------------------------------------------------------------").

add_property( Connection, Key, PropertyName, Value) -> 
                          Driver = connect(Connection),
                          apply(Driver, add_property, [Connection, Key,PropertyName, Value]),
                          ok.









has_property_help() -> 
p("---------------------------------------------------------------------"),
p("-      has_property(ConnectionArgs, Record, PropertyName)           -"),
p("-                                                                   -"),
p("-       Tests to see whether a record has a particular property     -"),
p("-      and returns either true or false                             _"),
p("-                                                                   -"),
p("---------------------------------------------------------------------").

has_property(C,Record,PropertyName) -> Driver = connect(C),
                                       apply(Driver, has_property, [C, Record, PropertyName]),
                                       ok.







get_property_names_help() -> 
p("---------------------------------------------------------------------"),
p("-                    connect(ConnectionArgs)                        -"),
p("-                                                                   -"),
p("-                    connects to the database                       -"),
p("-                                                                   -"),
p("---------------------------------------------------------------------").

set_property(C, Key,Col,Value) -> update_property(C,Key,Col,Value).








get_property_names_help() -> 
p("---------------------------------------------------------------------"),
p("-                    connect(ConnectionArgs)                        -"),
p("-                                                                   -"),
p("-                    connects to the database                       -"),
p("-                                                                   -"),
p("---------------------------------------------------------------------").

set(C, Key,Col,Value) -> update_property(C,Key,Col,Value).








get_property_names_help() -> 
p("---------------------------------------------------------------------"),
p("-                    connect(ConnectionArgs)                        -"),
p("-                                                                   -"),
p("-                    connects to the database                       -"),
p("-                                                                   -"),
p("---------------------------------------------------------------------").

update_property(C, Key,Col,Value) -> Driver = connect(C),
                                     apply(Driver, update_property, [C, Key,Col,Value]),
                                     ok.





get_property_names_help() -> 
p("---------------------------------------------------------------------"),
p("-                    connect(ConnectionArgs)                        -"),
p("-                                                                   -"),
p("-                    connects to the database                       -"),
p("-                                                                   -"),
p("---------------------------------------------------------------------").

delete_property(C, Key, Property) -> delete_property(C, [{key,Key}, {property,Property}]).









get_property_names_help() -> 
p("---------------------------------------------------------------------"),
p("-                    connect(ConnectionArgs)                        -"),
("-                                                                   -"),
p("-                    connects to the database                       -"),
p("-                                                                   -"),
p("---------------------------------------------------------------------").

delete_property(C, Key, Property, Value) -> 
                   delete_property(C, [{key,Key}, {property,Property}, {value,Value}]).










get_property_names_help() -> 
p("---------------------------------------------------------------------"),
p("-                    connect(ConnectionArgs)                        -"),
p("-                                                                   -"),
p("-                    connects to the database                       -"),
p("-                                                                   -"),
p("---------------------------------------------------------------------").

delete_property(C, Args) ->  Driver = connect(C),
                             Key = proplists:get_value(key,Args),
                             Property = proplists:get_value(property,Args),
                             Value = proplists:get_value(value,Args),
                             case Value of 
                                 undefined -> apply(Driver, delete_property, [C, Key, Property]);
                                 _ -> apply(Driver, delete_property, [C, Key, Property, Value])
                             end,
                             ok.



get_property_names_help() -> 
p("---------------------------------------------------------------------"),
p("-                    connect(ConnectionArgs)                        -"),
p("-                                                                   -"),
p("-                    connects to the database                       -"),
p("-                                                                   -"),
p("---------------------------------------------------------------------").

exists(Connection,Key) -> Driver = connect(Connection),
                          Exists = apply(Driver, exists, [Connection, Key]),
                          Exists.











get_property_names_help() -> 
p("---------------------------------------------------------------------"),
p("-                    connect(ConnectionArgs)                        -"),
p("-                                                                   -"),
p("-                    connects to the database                       -"),
p("-                                                                   -"),
p("---------------------------------------------------------------------").

delete(Connection,Key) -> Driver = connect(Connection),
                          apply(Driver, delete, [Connection, Key]),
                          ok.








get_property_names_help() -> 
p("---------------------------------------------------------------------"),
p("-                    connect(ConnectionArgs)                        -"),
p("-                                                                   -"),
p("-                    connects to the database                       -"),
p("-                                                                   -"),
p("---------------------------------------------------------------------").

ls(Connection) ->           Driver = connect(Connection),
                            Ls = apply(Driver, ls, [Connection]),
                            Ls.










get_property_names_help() -> 
p("---------------------------------------------------------------------"),
p("-                    connect(ConnectionArgs)                        -"),
p("-                                                                   -"),
p("-                    connects to the database                       -"),
p("-                                                                   -"),
p("---------------------------------------------------------------------").

count(Connection) ->  Driver = connect(Connection),
                      Count = apply(Driver, count, [Connection]),
                      Count.








get_property_names_help() -> 
p("---------------------------------------------------------------------"),
p("-                    connect(ConnectionArgs)                        -"),
p("-                                                                   -"),
p("-                    connects to the database                       -"),
p("-                                                                   -"),
p("---------------------------------------------------------------------").

delete_all( Connection , yes_im_sure ) -> Driver = connect( Connection ),
                                          apply( Driver , delete_all , [ Connection ,  yes_im_sure ] ),
                                          ok.









get_property_names_help() -> 
p("---------------------------------------------------------------------"),
p("-                    connect(ConnectionArgs)                        -"),
p("-                                                                   -"),
                             
p("-                    connects to the database                       -"),
                             
p("-                                                                   -"),
                             
p("---------------------------------------------------------------------").
test() -> test_riak().
          % test_mnesia().









get_property_names_help() -> 
p("---------------------------------------------------------------------"),
                             
p("-                    connect(ConnectionArgs)                        -"),
                             
p("-                                                                   -"),
                             
p("-                    connects to the database                       -"),
                             
p("-                                                                   -"),
                             
p("---------------------------------------------------------------------").
test_riak() ->
                RiakConnection = [{driver,db_riak_driver},{hostname,'riak@127.0.0.1'},{bucket,<<"default">>}],
                test(RiakConnection).










get_property_names_help() -> 
p("---------------------------------------------------------------------"),
                             
p("-                    connect(ConnectionArgs)                        -"),
                             
p("-                                                                   -"),
                             
p("-                    connects to the database                       -"),
                             
p("-                                                                   -"),
                             
p("---------------------------------------------------------------------").

local() -> RiakConnection = [{driver,db_riak_driver},{hostname,'riak@127.0.0.1'},{bucket,<<"default">>}],
           RiakConnection.










get_property_names_help() -> p("---------------------------------------------------------------------"),
                             p("-                    connect(ConnectionArgs)                        -"),
                             p("-                                                                   -"),
                             p("-                    connects to the database                       -"),
                             p("-                                                                   -"),
                             p("---------------------------------------------------------------------").
test(C) ->      println("Number of records in datastore:"),
                Count = count(C),
                print_number(Count),

                delete_all(C,yes_im_sure),                

                set(C, "boy", "Is here"),
                println("\nSaved 'boy' as 'is here'"),
                Value = get(C, "boy"),
                println("got value of boy as : "),               
                println(Value),
                println("Check 'boy' exists :"),
                Exists = exists(C, "boy"),
                println(Exists),
                delete(C,"boy"),
                println("deleted 'boy'"),
                println("Check 'boy' exists :"),
                Exists2 = exists(C, "boy"),
                println(Exists2),
                println("-----------------------"),

                LogEntry = create(C),
                set(C,LogEntry,"type","log").

%----------------------------------------------------------------------------------

                