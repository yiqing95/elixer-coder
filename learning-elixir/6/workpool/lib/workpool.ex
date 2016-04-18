defmodule Workpool do

 def start do
      pid = Workpool.Scheduler.start_link
      true = Process.register(pid, :scheduler)
      :ok
  end

 def  queue(fun, args) do
    send :scheduler, {:queue, fun , args, self}
    :ok
 end
end
