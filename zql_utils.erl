-module(zql_utils).
-compile(export_all).

help() -> println("----------------------------------------------------------"),
          println("-                     MODULE zprint                      -"),
          println("- Handles all printing issues to the console             -"),
          println("----------------------------------------------------------"),
 
          println("nl                    newline"),
          println("println(Text)         prints Text plus a linefeed"),
          println("p(Text)                     "),
          println("print_number(N)       print number N plus a linefeed"),
          println("----------------------------------------------------------").

nl() -> println("").

p(Line) -> println(Line).

print(Line)  ->   io:fwrite(Line).

q(Atom) -> String = atom_to_list(Atom),
            p(String).

print_number(N) ->   io:format("~w~n", [N]).

println(Line)  ->   io:fwrite(Line),
                    io:fwrite("~n").

to_binary(Value) when is_binary(Value) -> Value;
to_binary(Value) when is_list(Value) -> list_to_binary(Value).

hex_uuid() -> UUID_with_newline = os:cmd("uuidgen"),
              UUID_without_newline = lists:sublist( UUID_with_newline ,1,36),
              UUID_without_newline.

uuid() -> hex_uuid().

remove_newline(Line) -> Length = length(Line),
                        NewLine = lists:sublist( Line, Length - 1),
                        NewLine.

get_timestamp_microseconds() ->
    {Mega,Sec,Micro} = erlang:now(),
    (Mega*1000000+Sec)*1000000+Micro.

to_string(I) when is_integer(I) -> lists:flatten(io_lib:format("~p", [I]));
to_string(S) when is_list(S) -> S;
to_string(S) when is_binary(S) -> binary_to_list(S).


to_integer(I) when is_binary(I) -> to_integer(to_string(I));
to_integer(I) when is_integer(I) -> I;
to_integer(S) when is_list(S) -> 
                                 {I,_}=string:to_integer(to_string(S)),
                                 I.

readlines(FileName) ->
    {ok, Device} = file:open(FileName, [read]),
    get_all_lines(Device, []).



get_all_lines(Device, Accum) ->
    case io:get_line(Device, "") of
        eof  -> file:close(Device), Accum;
        Line -> get_all_lines(Device, Accum ++ [Line])
    end.




