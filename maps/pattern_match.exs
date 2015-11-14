person = %{ name: "YiQing" , height: 1.76 ,  }
%{name: a_name} = person
IO.puts a_name

%{name: _ , height: _ } = person

%{name: "YiQing"} = person # 如果左右侧不匹配会报错哦 ！