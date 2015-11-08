fun1 = fn -> fn -> "hello" end end

fun1.() # 第一次调用 返回一个函数
IO.puts fun1.().() # 对返回的函数再次调用

# 下面调用是一样的
fun2 = fun1.()
IO.puts fun2.()

# 参数记忆 闭包
greeter = fn
                name -> ( fn -> " Hello #{name} " end)

                end
yiqing_greeter = greeter.( "yiqing" )

IO.puts yiqing_greeter.()

# 都有参数
puts = fn a -> IO.puts a end # 定义方法别名 IO.puts 有些长！
add_n = fn n -> (fn other -> n + other end) end

puts.(add_n.(3).(5))

# 练习
prefix = fn pre ->  (fn others -> pre <> others end ) end
p1 = prefix.("y_")
puts.( p1.("_this is others parts "))
puts.( p1.(" hi do you see me "))

p2 = prefix.("my< ")

puts.(p2.("doodoodood " ))
puts.(p2.(" hhehehehehheh " ))