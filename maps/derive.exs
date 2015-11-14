defmodule Attendee do
    @derive Access
    defstruct name: "" , over_18: false
end

# a = %Attendee{name: "Yiqing", over_18: true}
# IO.puts a.name
# IO.puts a[:name]

