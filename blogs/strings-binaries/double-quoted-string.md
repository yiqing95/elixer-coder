双引号括起来的字符串 是二进制
==========================

单引号括起来的字符串是字符列表

而双引号括起来的字符串存储为utf-8编码的字节序列

由于utf-8字符可能占位多于单字节 二进制的位数可能会跟字符串长度不一致。

~~~[iex]

    iex(17)> dqs = "@yiqing"
    "@yiqing"
    iex(18)> String.length dqs
    7
    iex(19)> dqs = "@yiqing呀"
    "@yiqing呀"
    iex(20)> String.length dqs
    8
    iex(21)> byte_size dqs
    9
    iex(22)> String.at(dqs , 0 )
    "@"
    iex(23)> String.codepoints(dqs)
    ["@", "y", "i", "q", "i", "n", "g", "呀"]
    iex(24)> String.split(dqs,"/")
    ["@yiqing呀"]
~~~

##  字符串  elixir相关的库

elixir中的字符串 多指 双引号形式 
String 模块定义了一些工作于双引号形式的字符串函数
-  at(str,offset)

-  capitalize(str)

-  codepoints(str)

-  downcase(str)

-  duplicate(str,n)

-  end_with?(str , suffix | [ suffixes ] )

-   first(str)

-  graphemes(str)

-   last(str)

-   length(str)

-   ljust(str, new_length , padding \\ " " )  补齐

-   lstrip(str)
     lstrip(str , character )
     
-   next_codepoint(str)
     
-    next_grapheme(str)
     
-    printable?(str)
     
-    replace(str , pattern , replacement , options \\ [global:true , insert_replaced:nil ])    
 
-     reverse(str)
 
 -    rjust(str , new_length , padding \\ " ")
 
 -     rstrip(str)
 
 -    rstrip(str, character)
 
 -     slice(str , offset ,len )
 
 -    split(str , pattern \\ nil , options \\ [ global: true ])
 
 -     starts_with?(str , prefix | [ prefixes ] )
 
 -     strip(str)
 
 -     strip(str , character)
 
 -    upcase(str)
 
 -      valid_character?(str)
 
 -    ...  to be continue ...
