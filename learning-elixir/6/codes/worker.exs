defmodule Worker do
       def do_work() do
           receive do
               {:compute, x , pid } ->
                   send pid, {:result, x * x}
           end
       end

       # do_work() # 这个不管用！


   end

#   Worker.do_work()