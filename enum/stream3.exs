IO.puts
    File.stream!("stream1.exs")
    |> Enum.max_by( &String.length/1)