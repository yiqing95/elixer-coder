defmodule PingPong do
  @moduledoc false
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [] , [name: __MODULE__ ] ++ opts)
  end

  def ping() do
    GenServer.cast(__MODULE__, {:ping, self() })
  end

  def handle_cast({:ping, from} , state) do
    send from, :pong
    {:noreply, state}
  end

end