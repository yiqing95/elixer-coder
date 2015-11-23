二进制
================

二进制类型 代表 字节 的序列   

字面量看起来： << term ,... >> 
term 的范围 0 到 255

~~~[iex]
        
        iex(4)> b = <<1,2,3>>
        <<1, 2, 3>>
        iex(5)> byte_size b
        3
        iex(6)> bit_size b
        24
~~~
用修饰符来设置大小（位） 在网络或二进制格式相关的工作是很有用

~~~[iex]
    
    iex(7)> b = << 1::size(2) , 1::size(3) >>
    <<9::size(5)>>
    iex(8)> byte_size b
    1
    iex(9)> bit_size b
    5
~~~

存储 整数  浮点  或者其他二进制位二进制 

~~~[iex]
    
    iex(10)> int = << 1 >>
    <<1>>
    iex(11)> float = << 2.5:: float>>
    <<64, 4, 0, 0, 0, 0, 0, 0>>
    iex(12)> mix = << int :: binary , float :: binary >>
    <<1, 64, 4, 0, 0, 0, 0, 0, 0>>

~~~

~~~[IEX]

    iex(15)> << sign::size(1) , exp::size(11) , mantissa::size(52) >>  = << 3.14159::float >>
    <<64, 9, 33, 249, 240, 27, 134, 110>>
    iex(16)> (1 + mantissa / :math.pow(2,52)) * :math.pow(2,exp-1023)
    3.14159
~~~
