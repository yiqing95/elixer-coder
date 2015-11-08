# & 符号

add_one = &(&1 + 1 ) #  等价  add_one = fn n -> n+1  end

IO.puts(add_one.(5)) # expect 6

# 平方
fn_square = &( &1 * &1 )

IO.puts(fn_square.(5)) # expect 25

# 函数别名

speak = &(IO.puts(&1))

speak.("Hello yiqing")

#  & 会把其后的表达式 转化为函数 在括号中出现的 &1 &2 分别对应的是参数占位1,2
# &( &1 + &2 ) 等价  fn p1 ,p2 -> p1 + p2 end

#  [] {} 也是操作符
divrem = &{ div(&1,&2) , rem(&1,&2) } #  将元祖转换为函数
# speak.( divrem.(13,5) ) # FIXME 暂时还没学习如何打印元祖 所以先用此方法  虽然会报错 但仍能看到执行结果！

# 函数别名2
l = &length/1       #  length 函数的签名在Elixir中是 :  length/1   IO.puts的签名是IO.puts/1
speak.(l.([2,4,5])) # except 3

io_puts = &IO.puts/1
io_puts.( 'hi  do you see this ')

# 别名练习
len = &Enum.count/1
io_puts.( len.([1,2,3,4,5 ])) # expect 5

m = &Kernel.min/2 # 这是一个erlang 函数的别名 有两个参数 求最小值
io_puts.( m.(10,3) ) # expect 3

#  & 给我们了一个方便强大的方式写 匿名函数
Enum.map [1,2,3,4] , &(&1+1)      # 对列表中的每个元素+1
Enum.map [1,2,3,4] , &(&1*&1)     # 自己相乘 => [1,4,9,16]
Enum.map [1,2,3,4] , &(&1 < 3)    # TODO ？ 不清楚 <  是什么操作符 在学本章时！


# 练习
Enum.map [1,2,3,4] , &(&1+2)
Enum.map [1,2,3,4] , &(IO.inspect &1)