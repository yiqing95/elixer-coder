defmodule FilterService do
    use GenServer

    def start_link(opts \\ []) do
        GenServer.start_link(__MODULE__, nil , [name: {:global, __MODULE__}] ++ opts)
    end

    def init(_)  do
        {:ok, %{} }
    end

    def filter(collection, predicate) do
        pid = :global.whereis_name __MODULE__
        GenServer.cast(pid, {:filter, collection, predicate, self})
    end

    def handle_cast({:filter, collection, predicate, sender}, state) do
        send sender, {:filter_results, collection |> Enum.filter(predicate) }
        {:noreply, state}
    end
end