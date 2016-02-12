defmodule KV do
  @moduledoc false

  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init() do
    {:ok, HashDict.new}
  end

  ## 处理消息
 def handle_call({:put, key, value}, _from, dictionary) do
 {:reply, :ok, HashDict.put(dictionary, key, value)}
 end
 def handle_call({:get, key}, _from, dictionary) do
 {:reply, HashDict.get(dictionary, key), dictionary}
 end

end