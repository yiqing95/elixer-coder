defmodule Sum do

    def values(dict) do
        dict |> Dict.values |> Enum.sum
    end
end

hd = [ one: 1 , wot: 2 , three: 3 ] |>
    Enum.into HashDict.new

IO.puts Sum.values(hd)

# sum a map
map = %{ four: 4 , five: 5 , six: 6 }

IO.puts Sum.values(map) # => 15

kw_list = [name: "dave" , likes: "programing" , where: "dallas" ]
hashdict = Enum.into kw_list , HashDict.new

map = Enum.into kw_list , Map.new
IO.puts kw_list[:name]
IO.puts hashdict[:name]
IO.puts map[:name]

hashdict = Dict.drop(hashdict , [:where,:likes])
IO.inspect hashdict

hashdict = Dict.put(hashdict , :also_kikes , "ruby")
IO.inspect hashdict

combo = Dict.merge(map,hashdict)
IO.inspect combo


kw_list = [ name: "Dave" , likes: "Programming" , likes: "Elixir" ]
IO.puts kw_list[:likes]
IO.puts Dict.get(kw_list , :likes)
# 多key
Keyword.get_values(kw_list , :likes ) |> IO.inspect




