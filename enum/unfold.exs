Stream.unfold({0,1} , fn {f1,f2} -> {f1,{f2,f1+f2}} end )
|> Enum.take(15)
|> IO.inspect