defmodule Debugger do
    defmacro log(expression) do
        if Application.get_env(:debugger, :log_level) == :debug do
            quote bind_quoted: [expression: expression ] do
                IO.puts "=============="
                IO.inspect expression
                IO.puts "=============="
                expression
            end
          else
            expression
        end
    end
end

##
'''
    iex> c "debugger.exs"
    [Debugger]
    iex> require Debugger
    nil
    iex> Application.put_env(:debugger, :log_level, :debug)
    :ok
    iex> remote_api_call = fn -> IO.puts("calling remote API...") end
    #Function<20.90072148/0 in :erl_eval.expr/5>
    iex> Debugger.log(remote_api_call.())
    =================
    calling remote API...
    :ok
    =================
    calling remote API...
    :ok
    iex>
'''