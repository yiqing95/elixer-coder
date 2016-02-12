defmodule PingPong do
  @moduledoc false

    def start_link(opts \\ []) do
    :proc_lib.start_link(__MODULE__, :init, [self(), opts])
    end

    def init(parent, opts) do
        debug = :sys.debug_options([])
        Process.link(parent)
        :proc_lib.init_ack(parent, {:ok, self()})
        Process.register(self(), __MODULE__)
        state = HashDict.new
        loop(state, parent, debug)
    end

    defp loop(state, parent, debug) do
        receive do
        {:ping, from} ->
          send from, :pong
        {:system, from, request} ->
          :sys.handle_system_msg(request, from, parent, __MODULE__,
          debug, state)
        end
        loop(state, parent, debug)
    end

    def system_continue(parent, debug, state), do: loop(state, parent,
    debug)
    def system_terminate(reason, _, _, _), do: exit(reason)
    def system_get_state(state), do: {:ok, state}

  def ping() do
      send __MODULE__, {:ping, self()}
         receive do
      {:reply, response} ->
          response
      after 10000 ->
          {:error, :timeout}
      end
  end
end