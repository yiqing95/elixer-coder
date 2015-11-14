##  List 模块的操作

[1,2,4] ++ [5,6,7] # 连接

List.flatten([ [ [1],[2]] , [[[3]]] ]  )


List.foldl([1,2,3] , "" , fn value , acc -> "#{value}(#{acc})" end )

l = List.zip([ [ 1,2,3] ,[:a,:b,:b] ,["cat","dog"] ])

List.unzip(l)

kw = [ {:name ,"Dave"} , {:likes , "Programming" }, {:where , "Dallas", "TX"} ]
List.keyfind(kw,"Dollas", 1 )
List.keyfind(kw,"TX",2)
List.keyfind(kw,"TX",1)

kw = List.keydelete(kw , "TX" , 2)

kw = List.keyreplace(kw, :name , 0 , { :first_name ,"Dave" } )

kw_list = [ name: "Dave" , likes: "Programming" , likes: "Elixir" ]
IO.puts kw_list[:likes]
