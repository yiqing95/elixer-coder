目前只有一个版本的集合实现：  HashSet

    >  iex(1)> set1 = Enum.into 1..5 , HashSet.new
       #HashSet<[2, 3, 4, 1, 5]>
       iex(2)> Set.member?  set1 , 3
       true
       iex(3)> set2 = Enum.into 3..8, HashSet.new
       #HashSet<[7, 6, 3, 4, 5, 8]>
   
集合合并
>
       iex(4)> Set.union set1 , set2
       #HashSet<[7, 6, 2, 3, 4, 5, 1, 8]>

集合求差
>
       iex(5)> Set.difference set1, set2
       #HashSet<[2, 1]>
       iex(6)> Set.difference  set2 , set1
       #HashSet<[7, 6, 8]>
   
集合求交集
   
>   
    iex(7)> Set.intersection set1 , set2
    #HashSet<[3, 4, 5]>
   