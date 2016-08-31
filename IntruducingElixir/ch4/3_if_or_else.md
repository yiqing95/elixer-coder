>
    if velocity > 20 do
        IO.puts("look out below")
    else
        IO.puts("Reasonable...")
    end

单行形式：
>  if  x>10  do  :large  end

> if x>10 do :large else :small end

短形式：
>   if x>10, do :large, else: :small

## if 的 反逻辑 unless

>  unless x>10, do: :small, else: :large

## 变量赋值 在case 和 if 构造中
case cond 或者if 都有一个机会绑定值到变量。
错误用法：
~~~

    def bad_cond(test_val)  do
        cond do
            test_val < 0 ->　x=1
            test_val >= 0 -> y=2
        end

        x+y
    end
~~~    
erlang 中会拒绝这样的做法 不让编译通过 让你知道 他们是 unsafe 变量
elixir 会让他编译通过  但会在运行期break掉

条件式 分支语句 因为有可能只走其中的一条 那么有的变量在此中赋值 该变量可能就不存在！ 比如上例中 x, y
而底部 x+y 假设x和y 都被赋值过！

## 温柔的边缘效应 IO.puts
这种边缘效应 在跟踪代码逻辑时比较有用

其他方法：
- IO.write 
- IO.inspect