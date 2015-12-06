defmodule TableFormatterTest do

    use ExUnit.Case

    # 测试目标 创建别名
    alias Issues.TableFormatter,  as: TF

    #  测试数据
    def spimple_test_data do
        [

        ]
    end
    def headers , do:   [ :c1, :c2 , :c3 ]

    def split_with_three_columns , do:
    #TF.split_into_columns(simple_test_data , headers)
    "底层委托给 目标的同名函数"


    # 测试
    test "split_into_columns " do
        asert 1 == 1
    end

end