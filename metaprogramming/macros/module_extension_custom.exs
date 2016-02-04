defmodule Assertion do
    # ...
    defmacro extend(options \\ []) do
        quote do
            import unquote(__MODULE__)

            def run do
                IO.puts "Running the tests ..."
            end
        end
    end
end

defmodule MathTest do
    require Assertion
    Assertion.extend
end

#
'''
iex(23)> c "module_extension_custom.exs"
module_extension_custom.exs:1: warning: redefining module Assertion
module_extension_custom.exs:3: warning: variable options is unused
module_extension_custom.exs:14: warning: redefining module MathTest
[MathTest, Assertion]
iex(24)> MathTest.run
Running the tests ...
:ok
'''