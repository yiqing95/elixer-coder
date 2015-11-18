IO.puts
    File.open!('pipeline.exs')
    |> IO.stream(:line)
    |> Enum.max_by(&String.length/1)