for x <- [1,2] , y <- [5,6] , do: x*y

for x <- [1,2] , y <- [5,6] , do: {x,y}

min_maxes = [{1,4} , {2,3} , {10,15} ]
for {min, max} <- min_maxes , n <- min..max  , do: n


first8 = [1,2,3,4,5,6,7,8]

for x <- first8 , y <- first8 , x>= y, rem(x*y ,10) == 0 , do: { x, y}

reports = [ dallas: :hot , minneapolis: :cold , dc: :muggy , la: :smoggy ]

for { city ,weather } <- reports , do: {weather , city }

for << << b1::size(2) , b2::size(3) , b3::size(3) >> <- "hello" >> , do: "0#{b1}#{b2}#{b3}"