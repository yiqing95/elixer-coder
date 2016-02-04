Multi-app 
=========
很不幸的是 Erlang选择把自包含的代码捆包称为apps，很多时候他们更接近共享库，并且当你的项目长大时，你可能想分割你的代码
 到多个库，或者apps。幸运的是mix使得这件事很轻松。
 
为了展示这个过程，我们将创建一个简单的Elixir 执行器，给定一些输入行，它返回对应的计算结果，这将是个app。

为了测试这个，我们需传递多个行构成的列表，我们已经实现了一个 ~l 魔术符 他可以为我们从多个行中创建出列表，因此我们让那些代码
居于独立的程序。
 
Elixir称这些多app项目 umbrella projects。
~~~   
   
    $ mix new --umbrella eval
    * creating .gitignore
    * creating README.md
    * creating mix.exs
    * creating apps
    * creating config
    * creating config/config.exs
    
    Your umbrella project was created successfully.
    Inside your project, you will find an apps/ directory
    where you can create and host many apps:
    
        cd eval
        cd apps
        mix new my_app
    
    Commands like "mix compile" and "mix test" when executed
    in the umbrella project root will automatically run
    for each application in the apps/ directory.
~~~
相较于常规的mix项目，umbrella 是非常轻量的，--- 只是一个mix文件 和一个apps 目录

## 创建子项目
Subproject 存于apps目录下，关于他们并没有其特之处 -- 他们只是简单的常规项目 使用mix new来创建 。让我们现在来创建两个项目。
~~~
    
     cd eval/apps
    
    yiqing@yiqing MINGW64 /f/Elixir-workspace/elixer-coder/blogs/adv-Elixir/multi-apps/eval/apps (master)
    $ mix new line_sigil
    * creating README.md
    * creating .gitignore
    * creating mix.exs
    * creating config
    * creating config/config.exs
    * creating lib
    * creating lib/line_sigil.ex
    * creating test
    * creating test/test_helper.exs
    * creating test/line_sigil_test.exs
    
    Your Mix project was created successfully.
    You can use "mix" to compile it, test it, and more:
    
        cd line_sigil
        mix test
    
    Run "mix help" for more commands.

    yiqing@yiqing MINGW64 /f/Elixir-workspace/elixer-coder/blogs/adv-Elixir/multi-apps/eval/apps (master)
    $ mix new evaluator
    * creating README.md
    * creating .gitignore
    * creating mix.exs
    * creating config
    * creating config/config.exs
    * creating lib
    * creating lib/evaluator.ex
    * creating test
    * creating test/test_helper.exs
    * creating test/evaluator_test.exs
    
    Your Mix project was created successfully.
    You can use "mix" to compile it, test it, and more:
    
        cd evaluator
        mix test
    
    Run "mix help" for more commands.
~~~
此时 我们可以试试我们的umbrella项目 ，返回到项目根目录 并试着用 mix compile
~~~
    
    yiqing@yiqing MINGW64 /f/Elixir-workspace/elixer-coder/blogs/adv-Elixir/multi-apps/eval/apps (master)
    $ cd ..
    
    yiqing@yiqing MINGW64 /f/Elixir-workspace/elixer-coder/blogs/adv-Elixir/multi-apps/eval (master)
    $ mix compile
    ==> evaluator
    Compiled lib/evaluator.ex
    Generated evaluator app
    ==> line_sigil
    Compiled lib/line_sigil.ex
    Generated line_sigil app
~~~

现在我们有一个umbrella项目 包含两个常规项目，因为子项目并无特别之处，你可以在其中使用所有常规mix的命令。然而，在最顶级，
你可以构建所有的子项目作为一个整体单元。

### 子项目的决定
实际上 子项目只是常规mix项目 意味着你不用担心 是否使用一个umbrella开始一个新项目。简单的从一个简单的项目开始，如果后面
你发现需要一个umbrella项目，创建它并将已经存在的项目移到apps目录即可。

### LineSigil项目
这个项目比较碎小 -- 只需要拷贝LineSigil 模块从前面的练习中 ，验证构建他通过运行 mix compile （最顶级目录 或者 
line_sigil 目录都可以）

### Evaluator 项目
evaluator接受字符串列表 包含Elixir表达式 并计算他们 ，他返回一个列表，包含表达式intermixed和其每个对应的值 ，比如 给出：
>
    a = 3
    b = 4
    a + b

我们的代码会返回：
>   
    code>  a = 3
    value> 3
    code>  b = 4
    value> 4
    code>  a + b
    value> 7

我们使用Code.eval_string 来执行Elixir表达式，为了得到从一个表达式传递给下个变量的值，我们也需要显示维护当前的绑定。    
~~~

    defmodule Evaluator do
        def eval(list_of_expressions) do
            { result, _final_binding } =
                Enum.reduce(
                    list_of_expressions,
                    { _result = [], _binding = binding() },
                    &evaluate_with_binding/2
                )
            Enum.reverse  result
        end
    
        defp evaluate_with_binding(expression, { result, binding }) do
            { next_result, new_binding } = Code.eval_string(expression, binding )
            { [ "value> #{next_result}", "code> #{expression}" | result], new_binding }
        end
    end
~~~

### 连接子项目
现在 我们需要测试我们的evaluator，使用我们的 ~l 魔术符来创建表达式列表很有意义，因此让我们以哪种方式来写我们的
测试，下面是我们想要写的一些测试：
~~~

    defmodule EvaluatorTest do
      use ExUnit.Case
      import LineSigil
      doctest Evaluator
    
      test "the truth" do
        assert 1 + 1 == 2
      end
    
      test "evaluates a basic expression " do
        input = ~l"""
          1 + 2
        """
        output = ~l"""
        code> 1+2
        value> 3
        """
        run_test input, output
      end
    
      test "variables are propogated " do
        input = ~l"""
        a = 123
        a + 1
        """
        output = ~l"""
        code> a = 123
        value> 123
        code> a + 1
        value> 124
    
        """
        run_test input, output
      end
      defp run_test(lines, output) do
        assert output == Evaluator.eval(lines)
      end
    end
~~~
但我们简单的运行它，Elixir会找不到LineSigil模块，为了补救这个我们需啊哟添加他到我们的项目依赖中,但我们只希望依赖出现在测试
环境，所以我们的mix.exs 变得有点复杂了。
~~~

    defmodule Evaluator.Mixfile do
      use Mix.Project
    
      def project do
        [app: :evaluator,
         version: "0.0.1",
         deps_path: "../../deps",
         lockfile: "../../mix.lock",
         elixir: "~> 1.1",
         build_embedded: Mix.env == :prod,
         start_permanent: Mix.env == :prod,
         deps: deps(Mix.env)]
      end
    
      # Configuration for the OTP application
      #
      # Type "mix help compile.app" for more information
      def application do
        [applications: [:logger]]
      end
    
      defp deps(:test) do
        [{
            :line_sigil,path: "../line_sigil"
        }] ++ deps(:default)
      end
    
      # Dependencies can be Hex packages:
      #
      #   {:mydep, "~> 0.3.0"}
      #
      # Or git/path repositories:
      #
      #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
      #
      # To depend on another app inside the umbrella:
      #
      #   {:myapp, in_umbrella: true}
      #
      # Type "mix help deps" for more examples and options
      defp deps(_) do
        []
      end
    end
~~~
跟常规配置不一样的是 deps 函数变为依赖环境返回不同的数组。
之后从我们顶级目录运行测试命令。 
>  
    $ mix test
    ==> line_sigil
    Compiled lib/line_sigil.ex
    Generated line_sigil app
    ..
    
    Finished in 0.2 seconds (0.2s on load, 0.03s on tests)
    2 tests, 0 failures
    
    Randomized with seed 176000
    ==> evaluator
    Compiled lib/evaluator.ex
    Generated evaluator app
    
    
      1) test evaluates a basic expression  (EvaluatorTest)
         test/evaluator_test.exs:10
         Assertion with == failed
         code: output == Evaluator.eval(lines)
         lhs:  ["code> 1+2", "value> 3"]
         rhs:  ["code>   1 + 2", "value> 3"]
         stacktrace:
           test/evaluator_test.exs:18
    
    ..
    
    Finished in 0.00 seconds
    3 tests, 1 failure
    
    Randomized with seed 392000

看到我们的测试有1个失败呢，由于空格问题导致输入于预期不等(左手边lhs:  1+2 ... 右手边rhs 1 + 2 )， 手动调整下直到通过为止。

注意从顶部运行测试命令 会跑遍子项目的测试的 