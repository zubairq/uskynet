-module(zql_riak_driver).
-compile(export_all).
-include_lib("zql_all_imports.hrl").

connect(Connection) -> Hostname = proplists:get_value(hostname, Connection),
                       {ok, C} = riak:client_connect(Hostname),
                       C.





get_property_names( ConnectionArgs, Key ) -> 

                                 Data = get( ConnectionArgs, Key ),
                                 NamesWithDuplicates = [ Prop || {Prop,_Value} <- Data ],
                                 NoDuplicatesSet = sets:from_list(NamesWithDuplicates),
                                 UniqueList = sets:to_list(NoDuplicatesSet),
                                 UniqueList.



get_property( ConnectionArgs, Key, PropertyName) -> 

                                 Data = get( ConnectionArgs, Key ),
                                 Value = [ {Prop,Value} || {Prop,Value} <- Data, Prop == PropertyName ],
                                 [{_PN, V} | _] = Value,
                                 V.





has_property( ConnectionArgs, Key, PropertyName) -> 

                                               PropertyNames = get_property_names( ConnectionArgs, Key),
                                               ContainsKey = lists:member( PropertyName, PropertyNames),
                                               ContainsKey.





get( ConnectionArgs, Key ) -> RiakClient = connect( ConnectionArgs ),
                              BinaryKey = to_binary( Key ),
                              Bucket = proplists:get_value( bucket, ConnectionArgs ),
                              { ok, Item } = RiakClient:get(
                                  Bucket,
                                  BinaryKey,
                                  1),

                              Value = riak_object:get_value( Item ),
                              Value.








set( ConnectionArgs, Key, Value) -> RiakClient = connect( ConnectionArgs ),
                                    BinaryKey = to_binary(Key),
                                    Bucket = proplists:get_value( bucket, ConnectionArgs ),
                                    Item = riak_object:new( Bucket, BinaryKey, Value ),
                                    RiakClient:put( Item , 1),
                                    ok.









create_record(ConnectionArgs) -> UUID = uuid(),
                                 create_record(ConnectionArgs, UUID).


create_record(ConnectionArgs, Id) -> 

                                 Key = list_to_binary(Id),
                                 RiakClient = connect( ConnectionArgs ),
                                 Bucket = proplists:get_value( bucket, ConnectionArgs ),
                                 Item = riak_object:new( Bucket, Key, [] ),
                                 RiakClient:put( Item , 1),
                                 Key.








add_property(C, Key, PropertyName, Value) ->    RiakClient = connect( C ),
                                                Bucket = proplists:get_value(bucket, C),
                                                BinaryKey = to_binary(Key),

                                                { ok, Item } = RiakClient:get(
                                                    Bucket,
                                                    BinaryKey,
                                                    1),
                                                CurrentValues = riak_object:get_value( Item ),
                                                UpdatedValue = [{PropertyName,Value} | CurrentValues],

                                                UpdatedItem = riak_object:update_value(
                                                    Item,
                                                    UpdatedValue),
                                                RiakClient:put( UpdatedItem, 1).










update_property(Connection, Key,Property,Value) -> 
                            RiakClient = connect( Connection ),
                            Bucket = proplists:get_value(bucket, Connection),

                            { ok, Item } = RiakClient:get(
                                 Bucket,
                                 Key,
                                 1),

                            CurrentValues = riak_object:get_value( Item ),
                            DeletedPropertyList = delete_property_list( Property, CurrentValues),
                            UpdatedValue = [{Property,Value} | DeletedPropertyList],

                            UpdatedItem = riak_object:update_value(
                                                 Item,
                                                 UpdatedValue),

                            RiakClient:put( UpdatedItem, 1).                                       






delete_property(Connection, Key, Property) -> RiakClient = connect( Connection ),
                                       Bucket = proplists:get_value(bucket, Connection),
                                       { ok, Item } = RiakClient:get(
                                           Bucket,
                                           Key,
                                           1),

                                       CurrentValues = riak_object:get_value( Item ),
                                       UpdatedValue = delete_property_list( Property, CurrentValues ),

                                       UpdatedItem = riak_object:update_value(
                                           Item,
                                           UpdatedValue),

                                       RiakClient:put( UpdatedItem, 1),
                                       ok.








delete_property(ConnectionArgs, Key,Property, Value) -> 

                                RiakClient = connect( ConnectionArgs ),
                                Bucket = proplists:get_value(bucket, ConnectionArgs),

                                { ok, Item } = RiakClient:get(
                                     Bucket,
                                     Key,
                                1),
                                CurrentValues = riak_object:get_value( Item ),
                                UpdatedValue = lists:delete( { Property, Value },  CurrentValues ),

                                UpdatedItem = riak_object:update_value(
                                    Item,
                                    UpdatedValue),

                                RiakClient:put( UpdatedItem, 1).
                                       

delete_property_list( _Col, [] ) -> [];
delete_property_list( Col, [{Col,_AnyValue} | T ]) -> delete_property_list( Col, T);
delete_property_list( Col, [H | T]) -> [ H | delete_property_list(Col, T) ].






exists(Connection, Key) ->  RiakClient = connect( Connection ),
                            BinaryKey = to_binary(Key),
                            Bucket = proplists:get_value(bucket, Connection),

                            try
                                { ok, _Item } = RiakClient:get(
                                    Bucket,
                                    BinaryKey,
                                    1)
                            of
                                _ -> true
                            catch
                                error:_Reason -> false
		            end.






delete(Connection, Key) ->      RiakClient = connect( Connection ),
                                BinaryKey = to_binary(Key),
                                Bucket = proplists:get_value(bucket, Connection),

                                RiakClient:delete( Bucket, BinaryKey, 1 ),
 		       	    	ok.






ls(Connection) -> RiakClient = connect( Connection ),
                  Bucket = proplists:get_value(bucket, Connection),
                  {ok,Keys} = RiakClient:list_keys( Bucket ),
                  Keys.








count(Connection) -> Keys = ls(Connection),
                     Count = length(Keys),
                     Count.







delete_all( ConnectionArgs , yes_im_sure ) ->  Keys = ls( ConnectionArgs ),
                                               DeleteFunction = fun(Key) -> delete( ConnectionArgs , Key ) end,
                                               lists:map( DeleteFunction , Keys),
                                               ok.


