Stream.repeatedly(fn -> true end )
|> Enum.take(3)
# |> IO.puts

Stream.repeatedly( &:random.uniform/0 )
|> Enum.take(3)
|> IO.inspect
