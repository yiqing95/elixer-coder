 Stream.cycle(~W{ green white})
    |> Stream.zip(1..5)
    |> Enum.map( fn {class ,value} ->  ~s{<tr class="#{class}"> <td> #{value}</td></tr> \n }  end )
    |> IO.puts