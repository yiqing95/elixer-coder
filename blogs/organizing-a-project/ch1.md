- 项目结构

- mix 构建工具

- ExUnit 测试框架

- DocTests

让我们停止hacking 严肃起来

比如你想组织你的源代码，写测试，处理任何依赖 ，并且你想遵从Elixir的惯例 因为这样你可以从工具或者支持

例子程序  issues
-----------
    
从github获取issues
    
github提供了很棒的web api 用来取回issures ，简单的通过使用Get请求就可以了
    https://api.github.com/repos/user/project/issues
通过这个 我们将得到一个json列表 , 我们将重新格式 排序之 并过滤掉最老的n个 经结果处理成表格 。
    
### 我们程序应该怎么做到

我们程序应该从命令行运行 ，我们需要传递一个用户名，项目名称 ，和可选的count参数给github ，这意味着我们需要一些基本的命令行
解析 。

我们需要访问github 作为一个http客户端 ， 所以我们不得不找一个给我们Http客户端能力的库 ，返回结果是JSON ，所以我们也需要
找一个能够处理JSON的库  ， 我们需要能偶对结果结构进行排序 ，最终我们需要把选中的字段展示在表格中。

我们可以用一个词 生产线来想象这种数据转换 ，原始数据从一个端进入，并在每个站中轮流转换 。
 我们看到 数据 开始于命令行 ， 结束于一个漂亮的表格化展示 。在每个阶段 他经历了转换（解析 ，获取 ，等等） ，这些转换就是我们
 写的函数，我们将逐一揭示他们 。
 
任务 ： 使用Mix 来创建我们的项目
----------
Mix 是一个命令行工具 ，它用来管理Elixir程序的 。使用它创建一个新的项目，管理程序的依赖 ，运行测试 ，并运行我们的程序 。
如果已经安装了Elixir那么也就安装了Mix 。  
~~~cmd
  
    mix help 
~~~  
用上面的命令 查看帮助 。

>  mix help deps

我们也可以创建自己的mix任务 或者为了单独的项目或者在多个项目间共享。

### 创建 项目树
每个elixir项目 住在他们自己的目录树下，如果使用mix来管理这些树，那么就要遵从mix的惯例 （也是Elixir社区的惯例）

我们将称我们的项目为issues ，所以讲位于一个issures的目录，我们会使用mix来创建这个目录的 。
找个你想放置项目的目录
>  mix new issues
~~~

    yiqing@YIQING /F/Elixir-workspace/elixer-coder/projects (master)
    $ mix new issues
    * creating README.md
    * creating .gitignore
    * creating mix.exs
    * creating config
    * creating config/config.exs
    * creating lib
    * creating lib/issues.ex
    * creating test
    * creating test/test_helper.exs
    * creating test/issues_test.exs
    
    Your Mix project was created successfully.
    You can use "mix" to compile it, test it, and more:
    
        cd issues
        mix test
    
    Run "mix help" for more commands.
~~~

看到项目的结构已经生成。
将目录切换到issues/ 此时是开始版本控制的好时机 。
~~~
    
    git init
    git add .
    git commit -m "Initial commit of new project"

~~~
我们的新项目有三个目录 七个文件：
-  .gitignore
     版本控制工具用的
- README.md 
     项目描述的地方 （markdown 格式）
- config /
    应用特定的配置
- lib/
    此是我们项目源码居住的非，Mix已经添加了顶级模块( 我们的情形下是 issues.ex )
- mix.exs
    此源码文件包含我们项目的配置选项，项目进展中会不断添加新东西的。
- test/
    存放我们测试的地方，Mix已经创了帮助文件以及桩 用来做我们的issue模块测试 。

接下来我们的任务就是添加我们的代码。但开始之前，让我们想想实现问题。

## 变换： 解析命令行

让我们开始于命令行，我们真的不想在我们的主体程序中来重复处理命令行的选项。所以让我们写一个独立的模块作为我们程序和用户
输入的接口 ，依惯例 这个模块称为 Project.CLI (所以我们的代码应该在 Issues.CLI) ,同样依惯例 ，此模块的主入口是一个称为run
的函数，该函数接受一个命令行参数数组。

这个模块应该放哪里？
Elixir 有个惯例，在lib目录中 创建一个子目录 跟其项目名称一样（所以是 lib/issues/） 此目录会包含我们的程序的主要源码 。一
个模块一个文件 。 并且每个模块都在名空间Issues 模块下。模块命名随目录命名。
   
此情况下，我们要写的模块是Issues.CLI --- 是内嵌于Issues模块下的CLI模块 ，让我们来在目录结构上反映出来 并把cli.ex 放在 
lib/issues 目录下 。

lib
issues
    cli.ex
issues.ex
    
Elixir 随带了一个可选的 option-parsing库 ，
我们初始的CLI模块 看起来像这样：
~~~[elixir]

    defmodule  Issues.CLI do
    
        @default_count 4
    
        @moduledoc """
        Handle the command line parsing and the dispatch
        to the various functions that end up generating a
        table of the last _n_ issues in a github project
        """
    
        def run(argv) do
            parse_args(argv)
        end
    
        @doc """
        'argv' can be -h or --help , which returns :help.
        Otherwise it is a github user name , project name , and (optionally)
        the number of entries to format .
    
        Return a tuple of `{ user , project count }` , or `:help` if help was given
    
        """
    
        def parse_args(argv) do
            parse =
            OptionParser.parse( argv,
            switches: [help: :boolean ],
            aliases: [h:  :help ])
                case parse do
    
                { [ help: true ], _, _ }
                    -> :help
                    {_ , [ user, project , count ] , _ }
                    -> { user ,project ,count }
                    {_ , [user ,project ] ,_ }
    
                    -> { user ,project , @default_count }
    
                    _ -> :help
                end
          end
    end
~~~

Step: 写一些基本的测试
===========

至此，如果没有一些测试我们会感到些许不安的。幸运的是Elixir自带了一个很棒（且简单）的测试框架：ExUnit。

看下这个文件
test/issues_test.exs
~~~[elixir]
    
    defmodule IssuesTest do
      use ExUnit.Case
      doctest Issues
    
      test "the truth" do
        assert 1 + 1 == 2
      end
    end
~~~

它扮演了所有测试文件的模板角色 。当我们需要测试时 ，只需要拷贝并粘贴它到其他地方。

让我们来测试我们的CLI模块吧，把这些测试放在文件test/cli_test.exs .我们将测试 options parser是否能够探测 -h 和--help 选项。

     