defmodule Math_demo do
    
    def abs_val(num) when num < 0 do
        -num
    end

    def abs_val(num) when num == 0 do
       0
    end

    def abs_val(num) when num > 0 do
        num 
    end

end