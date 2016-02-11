defmodule KV do
  @moduledoc false

  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init() do
    {:ok, HashDict.new}
  end


end