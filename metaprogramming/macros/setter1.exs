defmodule Setter do
    defmacro bind_name(string) do
        quote do
            name = unquote(string)
        end
    end
end

# require Setter
# name = "Yiqing"
# Setter.bind_name("Max")
# IO.puts name