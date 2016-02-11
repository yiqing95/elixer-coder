defmodule Workpool.Scheduler do
  @moduledoc false

  def start_link do
    spawn_link(fn -> loop(%{processing: HashDict.new()}) end)
  end

  defp loop(state) do
    receive do
      {:queue, func, args, sender} ->
        {pid, _ref} = spawn_monitor(fn ->
          send sender, func.(args)
        end)
        processing = Dict.put(state.processing, pid, sender)
        loop(%{state | processing: processing})
      {:DOWN, _ref, :process, pid, :normal} ->
        loop(%{state | processing: Dict.delete(state.processing, pid) })
      {:DOWN, _ref, :process, pid, reason} ->
        sender = Dict.get(state.processing, pid)
        send sender, {:failure, "pool worker died: #{inspect reason}"}
        loop(%{state | processing: Dict.delete(state.processing, pid )})
    end
  end
end