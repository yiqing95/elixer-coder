������ --  ż������Ҫʹ�÷�֧
==================

������䣬Ҳ��֮Ϊ��֧���

### if and unless

Elixir ͬ��������һ�������Լ���if �� else �汾��Elixir Ҳ��if���߼����� **unless**
Ȼ����Щ�ṹ��Elixir���Ƿǳ��򵥵� ֻ�ܲ��� ����������
~~~

    x = 42
    if x>0 do
      IO.puts   x * -1
    
    end
    
    IO.puts x
~~~
>
    iex(4)> if 1>2 do
    ...(4)> "this is won't be retured"
    ...(4)> end
    nil
    iex(5)>
    
���� �κζ������Ǳ��ʽ����ʹ�Ƿ�֧��䡣������ʹ���ǻ���ĳЩ�����ֲ���ִ��·������֧�������ʽ�ᱻ��ʽ�ط��ء�
���� ���������������һϵ�еı��ʽ��һ�����һ�����ʽ�ᱻ���ء�   
>
    iex(5)> if true do
    ...(5)> x = 42
    ...(5)> y = x + 8
    ...(5)> z = x + y - 42
    ...(5)> z
    ...(5)> end
    50
    
��ʹʹ��else ���ʽҲ���طֲ�·�������ֵ
>
    iex(6)> if false do
    ...(6)> "nope"
    ...(6)> else
    ...(6)> "I will be returned"
    ...(6)> end
    "I will be returned"
    
��Ϊ���ʽ���뷵��ֵ��������������ʹ��ģʽƥ���ڷ��صı��ʽ�ϣ�
>
    iex(7)> 42 = if true do
    ...(7)> 42
    ...(7)> end
    42

**unless** ����if ��ʵ���ϣ���ʵ��Ϊif�ķ�ת
>
    iex(8)> nil = unless true do 42 end
    nil
    iex(9)> 42 = unless false do 42 end
    42

���⣬��if���ƣ�unless Ҳ��else ��
>
    iex(10)> "true" = unless true do 42 else "true" end
    "true"
    iex(11)>

ʵ�ʣ�ʹ��unless �ȼ��� if not condition ...:
>
    iex(12)> "false" = if not false do "false" else "true" end
    "false"
    
## the new else if
��Ϊ���ǲ�����ʽʹ�ã� if else if ���ʽ��
cond ��
~~~
    
    x = 42
    if x>0 do
      IO.puts   x * -1
    
    end
    
    IO.puts x
    
    cond do
    2 + 2 == 5 -> "For big values of 2"
    2 + 2 == 3 -> "For poorly sided squares ..."
    1 + 1 == 2 -> "Math seems to work."
    end

    iex(13)> import_file "if.exs"
    -42
    42
    "Math seems to work."
~~~
�⿴�������� ����C ���Ե� switch ��䡣
Ȼ��û��ͬswitch����еġ�fall through����Ϊ 

˳�����⣺
>
    cond do
    true -> "Always"
    true -> "Never"
    false -> "Similarly never"
    end
    "Always"
        
>
    x = 7
    y = 2
    cond do
    x + y > 8 ->
    y = x - y * div(x, y)
    x = y - x
    x - y < 0 ->
    x = y - x * div(y, x)
    y = x - y
    true -> "Else"
    end

ͨ�� -> �ѱ��ʽ���顣���ǿ���ʹ�������ı��ʽֻҪ�����Ķ��� ע������� ĩβ��true ��    
>
    iex(2)> cond do
    ...(2)> false  -> "This is never returned"
    ...(2)> end
    ** (CondClauseError) no cond clause evaluated to a true value

��˹�ͬʵ���������true ��Ϊ else ���ʽ��

������ ��Ϊ�κ����鶼��һ�����ʽ�����ǿ��԰� cond�Ľ�����ʽ��һ�����֣�
>
    iex(2)> result = cond do
    ...(2)> 2 + 2 == 5 -> "For large values of 2"
    ...(2)> 2 * 2 == 3 -> "For oddly shaped squares"
    ...(2)> 1 + 1 == 2 -> "Because math works"
    ...(2)> end
    "Because math works"
    iex(3)> IO.puts result
    Because math works
    :ok
    
һ�� ������Ҳ������cond�����ʹ��ģʽƥ�� 
    
## Elixir case ���ʽ

case ͨ cond ���ʽ���� ��������Ϊ����ģʽƥ�� ��

����ʹ��case ���ӱ��ػ��� ���Բ�ͬ�����ķ�֧ ���ڵ�����һ��ֵ ���˵� ����� C ���� Java�� switch��䡣
>
    iex(4)> mylist = [1, 2, 3, 4]
    [1, 2, 3, 4]
    iex(5)> case mylist do
    ...(5)> [a, 2, c, d] ->
    ...(5)> "Second element is 2"
    ...(5)> a + c * d - 2
    ...(5)> _ -> "Second element was _not_ 2"
    ...(5)> end
    iex: warning: code block starting at line contains unused literal "Second element is 2" (remove the literal or assign it to _ to avoid warnings)
    11

case ���ӽ���ģʽƥ�� ������ʹ�ø�����﷨����������ģʽƥ�����������ʽ ��
����ʹ�� _ �»��� ����ʧ����� �� �����������case����� �� else �־����Ϊ ��

��һ��case���ӣ�
>
    iex(6)> x = 1
    1
    iex(7)> case 10 do
    ...(7)> ^x -> "Won't match"
    ...(7)> end
    ** (CaseClauseError) no case clause matching: 10

## ʹ��branch ������
~~~

    defmodule FizzBuzz do
      @moduledoc false
    
      def print() do
        1..100 |> Enum.map( fn(x) ->
          cond do
            rem(x, 15) == 0 -> "FizzBuzz"
            rem(x, 3) == 0 -> "Fizz"
            rem(x, 5) == 0 -> "Buzz"
            true -> x
          end
        end) |> Enum.each(fn(x) -> IO.puts(x) end)
      end
    end
~~~
Ϊʲôû����Enum.map/2  Enum.map/2��Enum.each/2�Ĺؼ���������Ŀ�ĺͽ����
Enum.map/2 �������еĵ�ÿ��Ԫ�ؽ������Enum.each/2 ֻ����:ok ������������� ����ʺϴ�ӡÿ��Ԫ��
~~~
        
    iex(7)> import_file "fizz_buzz.ex"
    {:module, FizzBuzz,
     <<70, 79, 82, 49, 0, 0, 7, 40, 66, 69, 65, 77, 69, 120, 68, 99, 0, 0, 0, 130, 131, 104, 2, 100, 0, 14, 101, 108, 105, 120, 105, 114, 95, 100, 111, 99, 115, 95, 118, 49, 108, 0, 0, 0, 4, 104, 2, ...>>,
     {:print, 0}}
    iex(8)> FizzBuzz.print
    1
    2
    Fizz
    4
    Buzz
    Fizz
    7
    8
    Fizz
    Buzz
    11
    Fizz
    13
    14
    FizzBuzz
    16
    17
    Fizz
    19
    Buzz
    Fizz
    22
    23
    Fizz
    Buzz
    26
    Fizz
    28
    29
    FizzBuzz
    31
    32
    Fizz
    34
    Buzz
    Fizz
    37
    38
    Fizz
    Buzz
    41
    Fizz
    43
    44
    FizzBuzz
    46
    47
    Fizz
    49
    Buzz
    Fizz
    52
    53
    Fizz
    Buzz
    56
    Fizz
    58
    59
    FizzBuzz
    61
    62
    Fizz
    64
    Buzz
    Fizz
    67
    68
    Fizz
    Buzz
    71
    Fizz
    73
    74
    FizzBuzz
    76
    77
    Fizz
    79
    Buzz
    Fizz
    82
    83
    Fizz
    Buzz
    86
    Fizz
    88
    89
    FizzBuzz
    91
    92
    Fizz
    94
    Buzz
    Fizz
    97
    98
    Fizz
    Buzz
    :ok
~~~

## Mergesort �ϲ�����

���������������� O(n2) �� �ϲ������������� O(n log(n)).
