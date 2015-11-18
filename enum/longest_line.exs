IO.puts
File.read("/usr/share/dict/word")
|> String.split
|> Enum.max_by(&String.length/1)

## 上面也是消耗极重的代码段