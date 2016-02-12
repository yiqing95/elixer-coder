defmodule KV do
  @moduledoc false

  use GenServer

  def start_link(opts \\ []) do
    # GenServer.start_link(__MODULE__, [], opts)
    GenServer.start_link(__MODULE__, [], [name: __MODULE__] ++ opts)
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

  # 对外的门面方法
  '''
  def put(server, key, value) do
    GenServer.call(server, {:put, key, value})
  end
  def get(server, key) do
    GenServer.call(server, {:get, key})
  end
  '''

  def put(key, value) do
     GenServer.call(__MODULE__, {:put, key, value})
  end
  def get(key) do
     GenServer.call(__MODULE__, {:get, key})
  end
end