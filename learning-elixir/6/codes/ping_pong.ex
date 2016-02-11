defmodule PingPong do
  @moduledoc false

    def start_link do
      spawn_link(fn -> loop() end)
    end

    defp loop do
      receive do
        {:ping, sender} ->
          send sender, {:pong, self}
      end
      loop # 递归调用自己 等待下次:ping 消息。
    end
end

"""
  iex(39)> import_file "ping_pong.ex"
  {:module, PingPong,
   <<70, 79, 82, 49, 0, 0, 5, 244, 66, 69, 65, 77, 69, 120, 68, 99, 0, 0, 0, 135, 131, 104, 2, 100, 0, 14, 101, 108, 105, 120, 105, 114, 95, 100, 111, 99, 115, 95, 118, 49, 108, 0, 0, 0, 4, 104, 2, ...>>,
   {:loop, 0}}
  iex(40)> pid = PingPone.start_link
  ** (UndefinedFunctionError) undefined function: PingPone.start_link/0 (module PingPone is not available)
      PingPone.start_link()
  iex(40)> pid = PingPong.start_link
  #PID<0.132.0>
  iex(41)> send pid, {:ping, self}
  {:ping, #PID<0.57.0>}
  iex(42)> flush
  {:pong, #PID<0.132.0>}
  :ok
"""