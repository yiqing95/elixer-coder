x = 42
if x>0 do
  IO.puts   x * -1

end

IO.puts x

cond do
2 + 2 == 5 -> "For big values of 2"
2 + 2 == 3 -> "For poorly sided squares ..."
1 + 1 == 2 -> "Math seems to work."
end

cond do
true -> "Always"
true -> "Never"
false -> "Similarly never"
end

x = 7
y = 2
cond do
x + y > 8 ->
y = x - y * div(x, y)
x = y - x
x - y < 0 ->
x = y - x * div(y, x)
y = x - y
true -> "Else"
end