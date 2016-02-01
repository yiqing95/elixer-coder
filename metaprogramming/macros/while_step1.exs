defmodule Loop do
    defmacro while(expression, do: block) do
        quote do
            # 读取一个无限流来模拟while true
            for _ <- Stream.cycle([:ok]) do
                if unquote(expression) do
                    unquote(block)
                else
                # break out of loop
                end
            end
        end
    end
end