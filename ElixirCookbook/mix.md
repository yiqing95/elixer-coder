Elixir 安装提供了命令行工具叫Mix ， 是一个构建工具，
通过使用这个工具 ，可以调用多个任务来创建应用 ，管理其依赖 ，运行他们 。

Mix 甚至允许创建自己的客户化任务 。

>
        
    F:\Elixir-workspace\elixer-coder\ElixirCookbook\ch1\code>mix help
    mix                   # Runs the default task (current: "mix run")
    mix app.start         # Starts all registered apps
    mix archive           # Lists all archives
    mix archive.build     # Archives this project into a .ez file
    mix archive.install   # Installs an archive locally
    mix archive.uninstall # Uninstalls archives
    mix clean             # Deletes generated application files
    mix cmd               # Executes the given command
    mix compile           # Compiles source files
    mix deps              # Lists dependencies and their status
    mix deps.clean        # Deletes the given dependencies' files
    mix deps.compile      # Compiles dependencies
    mix deps.get          # Gets all out of date dependencies
    mix deps.unlock       # Unlocks the given dependencies
    mix deps.update       # Updates the given dependencies
    mix do                # Executes the tasks separated by comma
    mix escript.build     # Builds an escript for the project
    mix help              # Prints help information for tasks
    mix hex               # Prints Hex help information
    mix hex.build         # Builds a new package version locally
    mix hex.config        # Reads or updates Hex config
    mix hex.docs          # Publishes docs for package
    mix hex.info          # Prints Hex information
    mix hex.key           # Hex API key tasks
    mix hex.outdated      # Shows outdated Hex deps for the current project
    mix hex.owner         # Hex package ownership tasks
    mix hex.publish       # Publishes a new package version
    mix hex.registry      # Hex registry tasks
    mix hex.search        # Searches for package names
    mix hex.user          # Hex user tasks
    mix loadconfig        # Loads and persists the given configuration
    mix local             # Lists local tasks
    mix local.hex         # Installs Hex locally
    mix local.public_keys # Manages public keys
    mix local.rebar       # Installs rebar locally
    mix new               # Creates a new Elixir project
    mix phoenix.new       # Create a new Phoenix v1.0.4 application
    mix profile.fprof     # Profiles the given file or expression with fprof
    mix run               # Runs the given file or expression
    mix test              # Runs a project's tests
    iex -S mix            # Starts IEx and run the default task
    
    F:\Elixir-workspace\elixer-coder\ElixirCookbook\ch1\code>

mix 创建的项目结构中  依赖的 可以是github源（优先使用 [hex.pm](https://hex.pm)）：

在 mix.exs 中
~~~
    
    {:httpoison, "~> 0.4"}
    // github 源
    {:httpoison, github: " edgurgel/httpoison "}
    // 本地文件源
    {:httpotion, path: "path/to/httpotion"}
~~~
随应用启动的：
~~~

    def application do
    [applications: [:logger, :httpoison]]
    end
~~~
加载依赖：
~~~

    mix deps.get
~~~

编译 (递归解析依赖 编译)
>
    mix deps.compile
    
在iex会话中启动应用：
>
    iex –S mix.
    
检查依赖的应用是否已经启动：
>
    iex(1)> :application.which_applications
    
## 应用可用随supervision树生成来监控进程
supervision树必须随应用启动或者停止。应用模块必须实现一些回调，mix提供了很简单的方式来生成这种类型的应用。    
~~~shell

    mix new supervised_app --sup
~~~

## 生成 umbrella 应用
Erlang 方式中 是把每个自包含的代码单元称为app 有时，一个app 可能指的是其他语言中的库 。这是获得模块重用和模块化的好方法。
但有时，把项目中的所有应用视为单独实体比较方便。 umbrella应用作为一个容器 用来hold一个或者更多的应用来使他们表现为一个单
独应用。这运行更高级别的粒度 

创建
>
    F:\Elixir-workspace\elixer-coder\ElixirCookbook\ch1\code>mix new --umbrella container
    * creating .gitignore
    * creating README.md
    * creating mix.exs
    * creating apps
    * creating config
    * creating config/config.exs
    
    Your umbrella project was created successfully.
    Inside your project, you will find an apps/ directory
    where you can create and host many apps:
    
        cd container
        cd apps
        mix new my_app
    
    Commands like "mix compile" and "mix test" when executed
    in the umbrella project root will automatically run
    for each application in the apps/ directory.

在apps目录创建多个应用（任何类型 -- 应用类型递归的  即 一个umbrella应用 子应用也可以是umbrella类型 或者 sup应用） 
>
    F:\Elixir-workspace\elixer-coder\ElixirCookbook\ch1\code>cd container/apps
    
    F:\Elixir-workspace\elixer-coder\ElixirCookbook\ch1\code\container\apps>mix new app_one
    * creating README.md
    * creating .gitignore
    * creating mix.exs
    * creating config
    * creating config/config.exs
    * creating lib
    * creating lib/app_one.ex
    * creating test
    * creating test/test_helper.exs
    * creating test/app_one_test.exs
    
    Your Mix project was created successfully.
    You can use "mix" to compile it, test it, and more:
    
        cd app_one
        mix test
    
    Run "mix help" for more commands.
    
    
    F:\Elixir-workspace\elixer-coder\ElixirCookbook\ch1\code\container\apps>mix new app_two
    * creating README.md
    * creating .gitignore
    * creating mix.exs
    * creating config
    * creating config/config.exs
    * creating lib
    * creating lib/app_two.ex
    * creating test
    * creating test/test_helper.exs
    * creating test/app_two_test.exs
    
    Your Mix project was created successfully.
    You can use "mix" to compile it, test it, and more:
    
        cd app_two
        mix test
    
    Run "mix help" for more commands.

可以运行测试在最顶层级或者独立应用内
>
    F:\Elixir-workspace\elixer-coder\ElixirCookbook\ch1\code\container>mix test
    ==> app_one
    Compiled lib/app_one.ex
    Generated app_one app
    .
    
    Finished in 0.1 seconds (0.1s on load, 0.01s on tests)
    1 test, 0 failures
    
    Randomized with seed 574000
    ==> app_two
    Compiled lib/app_two.ex
    Generated app_two app
    .
    
    Finished in 0.00 seconds
    1 test, 0 failures
    
    Randomized with seed 731000

在独立应用根目录运行测试:
>
    F:\Elixir-workspace\elixer-coder\ElixirCookbook\ch1\code\container>cd apps/app_one
    
    F:\Elixir-workspace\elixer-coder\ElixirCookbook\ch1\code\container\apps\app_one>mix test
    Compiled lib/app_one.ex
    Generated app_one app
    .
    
    Finished in 0.06 seconds (0.06s on load, 0.00s on tests)
    1 test, 0 failures
    
    Randomized with seed 428000
    
## 管理应用配置
    
Mix 任务运行在特定环境，预定义的环境有 production ， development，和 test (prod dev test )
默认的环境是dev

配置文件中 动态加载特定配置(config/config.exs)：
>
    use Mix.Config
    config :config_example,
    message_one: "This is a shared message!"
    import_config "#{Mix.env}.exs"
    
## 创建自定义Mix任务
    
有时已有的Mix任务不够用，幸运的是，Mix运行我们创建自定义任务并集成到Mix中。    

1.  创建meminfo.ex 文件 

~~~
   
    defmodule Mix.Tasks.Meminfo do
      @moduledoc false
      use Mix.Task
    end
~~~
    
2. 添加任务描述 当使用 mix help命令时 会提取

>     @shortdoc"Get Erlang Vm memory usage information"
    
3. 添加新的任务模块文档

>
      @moduledoc """
      A mix custom task that outputs some information regarding
      the Erlang VM memory usage
      """

4. 创建run/1 函数：

~~~
    
    def run(_) do
        meminfo = :erlang.memory
        IO.puts """
        Total             #{meminfo[:total]}
        Processes         #{meminfo[:processes]}
        Processes (used)  #{meminfo[:processes_used]}
        System            #{meminfo[:system]}
        Atom.             #{meminfo[:atom]}
        Atom      (used)  #{meminfo[:atom_used]}
        Binary            #{meminfo[:code]}
        ETS               #{meminfo[:ets]}
        """
      end
~~~

5. 编译源码 使用Elixir编译器， 

    >   elixirc meminfo.ex
    如果不报错的话 会出现一个Elixir.Mix.Tasks.Meminfo.beam 文件
        
6. 运行 mix help  新添加的任务描述会出现的

~~~
        
    F:\Elixir-workspace\elixer-coder\ElixirCookbook\ch1\code>mix help
    mix                   # Runs the default task (current: "mix run")
    mix app.start         # Starts all registered apps
    mix archive           # Lists all archives     
       
       ...
       
       mix meminfo           # Get Erlang Vm memory usage information
       mix new               # Creates a new Elixir project
       mix phoenix.new       # Create a new Phoenix v1.0.4 application
       mix profile.fprof     # Profiles the given file or expression with fprof
       mix run               # Runs the given file or expression
       mix test              # Runs a project's tests
       iex -S mix            # Starts IEx and run the default task
~~~       
可以看到已经可以看到meminfo 自定义任务的短描述了
详细描述  **mix help <module>**
>
    F:\Elixir-workspace\elixer-coder\ElixirCookbook\ch1\code>mix help meminfo
    # mix meminfo
    
    A mix custom task that outputs some information regarding
    the Erlang VM memory usage
    
    Location: f:/Elixir-workspace/elixer-coder/ElixirCookbook/ch1/code

7. 执行自定义任务：

>
    F:\Elixir-workspace\elixer-coder\ElixirCookbook\ch1\code>mix meminfo
    Total             14932608
    Processes         4274728
    Processes (used)  4273512
    System            10657880
    Atom.             256313
    Atom      (used)  232076
    Binary            6127454
    ETS               355576
    
Mix的任务只是模块 定义为 **Mix.Tasks.<MODULENAME>** 并定义一个run函数
use Mix.Task 允许我们在当前上下文中使用指定模块（即 Mix.Task 模块）
@shortdoc 模块属性 允许我们定义短描述
   
   