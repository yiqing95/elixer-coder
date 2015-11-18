for x <- [1,2] , y <- [5,6] , do: x*y

for x <- [1,2] , y <- [5,6] , do: {x,y}

min_maxes = [{1,4} , {2,3} , {10,15} ]
for {min, max} <- min_maxes , n <- min..max  , do: n