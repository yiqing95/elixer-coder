cond 构造基本和case 语句类似 但是没有模式匹配。

如果你愿意，它允许你写出 catch-all 子句 ---》一个卫句在结尾匹配true 这经常使得 表达基于更广泛意义的比较 比简单的模式匹配 更简单

>
    def fall_velocity(planemo, distance) when distance >= 0 do
        gravity = case planemo do
            :earth -> 9.8
            :moon -> 1.6
            :mars -> 3.71
        end
        velocity = :math.sqrt(2 * gravity * distance)
        cond do
            velocity == 0 -> :stable
            velocity < 5 -> :slow
            velocity >= 5 and velocity < 10 -> :moving
            velocity >= 10 and velocity < 20 -> :fast
            velocity >= 20 -> :speedy   
        end
    end     

这回cond 构造返回一个值（原子用来描述速度） 它基于它内部的多个卫句 。
如果你想捕获cond 构造的返回 给一个变量的话 ：

discription = cond do ... 

! Elixir 对于cond 和if 语句 是基于truthiness 的 。 所有的值被认为是真的 除了nil 和false 。    