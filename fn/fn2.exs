times_2 = fn n -> n * 2 end

IO.puts(times_2.(3))

# 函数做为参数
apply = fn (fun , value) -> fun.(value) end

IO.puts(apply.(times_2,4)) # expect 8

# 内置的以函数做参点的例子

list = [1,3,5,7,9]

# IO.puts( Enum.map list , fn ele -> ele * 2 end  )
l2 = ( Enum.map list , fn ele -> ele * 2 end  )

IO.puts(l2)