defmodule Spawn4 do
  @moduledoc false

  def greet do

      receive do
          {sender , msg} ->
            send sender , {:ok , "Helllo , #{msg}"}
          # 递归啦！
          greet

      end
  end
end

# here is the client

pid = spawn(Spawn4 , :greet , [])

send pid , {self, "World!"}

receive do
      {:ok , msg} ->
        IO.puts msg
end

send pid , {self , "Yiqing"}
receive do
  {:ok ,msg} ->
    IO.puts msg
   after 500 ->
    IO.puts "The greeter has gone! "
end
