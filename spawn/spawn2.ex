defmodule Spawn2 do
  @moduledoc false

  def greet do
    receive do
      {sender ,msg} ->
        send sender , {:ok , "Hello #{msg}"}
    end
  end

end

# here is the client
pid = spawn(Spawn2 , :greet , [])

send pid , {self, "World!"}

receive do
  {:ok, message} ->
   IO.puts message
end

send pid , {self , "Yiqing "}
receive do
  {:ok, message } ->
    IO.puts message
end