defmodule Link2 do
  @moduledoc false

  import :timer , only:  [sleep: 1]

  def sad_function do
      sleep 500
      exit(:boom)
  end

  def run do
      spawn_link(Link2 , :sad_function , [])

      receive do
        msg ->
          IO.puts "MESSAGE RECEIVED #{inspect msg}"

        after 1000 ->
          IO.puts "Nothing happend as far as I am concerned "
      end

  end

end

#  运行
Link2.run