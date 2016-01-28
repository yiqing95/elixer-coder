defmodule My do
    defmacro macro(param) do
        IO.inspect param
    end
end

defmoudule Test do
    require My
    # These values reprtesent themselves
     My.macro :atom #=> :atom
     My.macro 1      #=>  1
     My.macro 1.0
     My.macro [1,2,3] #=> [1,2,3]
     My.macro do: 1   #=> [do: 1]
     My.macro do
        1
        end           #=>  [do: 1]
     # And these are represented by 3-element tuples
    My.macro {1,2,3,4,5} #=> {: "{}" ,[line: 20] ,[1,2,3,4,5]}

    My.macro do: (a=1; a+a) #=>
    #  [do:
    #      {:__block__,[],
    #           [{:= ,[line: 22], [{:a ,[line: 22],nil },1] },
    #             {:+, [line:22] , [{:a,[line:22],nil},{:a,[line:22],nil}]}]}]
    My.macro do #=> [do: {:+,[line: 24],[1,2]},else: {:+,[line: 26],[3,4]}]
        1+2
     else
        3+4
     end
end