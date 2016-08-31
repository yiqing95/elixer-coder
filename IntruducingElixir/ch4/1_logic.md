## 函数中的逻辑

case

cond

if

## 计算cases
case 构造可以让我们在函数内部执行模式匹配
>
    defmodule Drop do
        def fall_velocity(planemo, distance) when distance >= 0 do
            case planemo do
                :earth -> :math.sqrt(2 * 9.8 * distance)
                :moon -> :math.sqrt(2 * 1.6 * distance)
                :mars -> :math.sqrt(2 * 3.71 * distance)
            end
        end
    end

case 构造会比较原子 从列表中向下走 。 它不会处理匹配之外的东西 。每个匹配跟着一个 -> 你可以读其为"yields" case构造会根据所使用的原子来返回不同的计算结果。
因为case 构造返回函数句子中的最后一个值 ，函数也会返回那个值的。

你可以使用 下划线_ 在模式匹配中 如果你想选择它匹配“任何其他的东西” 然而你应该把它放在最后，任何他之后的东西都不会被执行计算的 ！

### 使用case 构造的返回值：
>   
    def fall_velocity(planemo, distance) when distance >= 0 do
        gravity = case planemo do
            :earth -> 9.8
            :moon -> 1.6
            :mars -> 3.71
        end
        :math.sqrt(2 * gravity * distance)
    end    

### 把卫士句 移到函数里面
>
    def  fall_velocity(planemo, distance) do
        gravity = case planemo do
            :earth when distance >= 0 -> 9.8
            :moon  when distance >= 0 -> 1.6
            :mars  when distance >= 0 -> 3.71
        end
        :math.sqrt(2 *　gravity * distance)
    end    

这个版本 会在参数错误时(没有找到匹配时)给出不同的错误;
>
    (FunctionClauseError) no function clause matching: Drop.fall_veloci
    ty(:mars, -20) to (CaseClauseError) no case clause matching: :mars:    