[ 1, 2,3,4,5 ]
|> Enum.map(&( &1 * &1 ))
|> Enum.with_index
|> Enum.map(fn {val , idx} -> val - idx end )
|> IO.inspect