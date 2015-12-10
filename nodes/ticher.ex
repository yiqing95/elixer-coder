defmodule Ticker do

    @interval 2000 # 2 seconds
    @name     :ticker

    def start do
        pid = spawn(__MODULE__ , :generator , [[]])
        :global.register_name(@name , pid )

    end

    def register(client_pid) do
        send :global.whereis_name(@name) ,{:register , client_pid }
    end

    def generator(clients) do
        receive do
            {:register , pid  } ->
                IO.puts "registering #{inspect pid}"
                generator([pid|clients])
        after
            @interval ->
                IO.puts "tick"
                Enum.each clients , fn client ->
                    send client ,{ :tick }
                 end
            generator(clients) # 等待注册或者超时两秒后发送心跳给所有已经注册的进程
        end
    end
end

