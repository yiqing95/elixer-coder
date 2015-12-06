OTP 是一个框架 用来管理运行程序的套件
~~~
           
      # Configuration for the OTP application
      #
      # Type "mix help compile.app" for more information
      def application do
        [applications: [:logger]]
      end
~~~
有个application的函数在我们的mix.exs 文件中

application 函数用来配置这些套件 ，默认时 此函数之上开始Elixir日志器 ，但我们可用此来启动额外的其他程序。（
    Elixir程序经常构造为互相协作的子程序 ，在其他程序中的 **库** 可以对应到elixie中的子应用 或许将之想象为组件或者服务
）
编译：
~~~
    
    yiqing@yiqing MINGW64 /f/Elixir-workspace/elixer-coder/projects/issues (master)
    $ iex -S mix
    Eshell V7.0  (abort with ^G)
    Could not find "rebar", which is needed to build dependency :idna
    I can install a local copy which is just used by Mix
    Shall I install rebar? [Yn] y
    * creating c:/Users/Lenovo/.mix/rebar
    ==> idna (compile)
    Compiled src/punycode.erl
    Compiled src/idna_unicode.erl
    Compiled src/idna.erl
    Compiled src/idna_ucs.erl
    Compiled src/idna_unicode_data.erl
    WARN:  Missing plugins: [rebar3_hex]
    ==> mimerl (compile)
    Compiled src/mimerl.erl
    ==> ssl_verify_hostname (compile)
    Compiled src/ssl_verify_hostname.erl
    ==> certifi (compile)
    Compiled src/certifi.erl
    Compiled src/certifi_cacerts.erl
    Compiled src/certifi_weak.erl
    ==> hackney (compile)
    Compiled src/socket/hackney_tcp_transport.erl
    Compiled src/socket/hackney_ssl_transport.erl
    Compiled src/socket/hackney_socks5.erl
    Compiled src/socket/hackney_pool_handler.erl
    Compiled src/socket/hackney_http_connect.erl
    Compiled src/metrics/hackney_folsom_metrics.erl
    Compiled src/metrics/hackney_exometer_metrics.erl
    Compiled src/metrics/hackney_dummy_metrics.erl
    Compiled src/socket/hackney_pool.erl
    Compiled src/socket/hackney_connect.erl
    Compiled src/http/hackney_url.erl
    Compiled src/http/hackney_response.erl
    Compiled src/http/hackney_multipart.erl
    Compiled src/http/hackney_request.erl
    Compiled src/http/hackney_http.erl
    Compiled src/http/hackney_cookie.erl
    Compiled src/http/hackney_date.erl
    Compiled src/http/hackney_headers.erl
    Compiled src/hackney_util.erl
    Compiled src/hackney_sup.erl
    Compiled src/http/hackney_bstr.erl
    Compiled src/hackney_trace.erl
    Compiled src/hackney_app.erl
    Compiled src/hackney_stream.erl
    Compiled src/hackney_manager.erl
    Compiled src/hackney.erl
    ==> httpoison
    Compiled lib/httpoison/base.ex
    Compiled lib/httpoison.ex
    Generated httpoison app
    ==> issues
    Compiled lib/issues.ex
    Compiled lib/issues/github_issues.ex
    Compiled lib/issues/cli.ex
    Generated issues app
    Interactive Elixir (1.1.1) - press Ctrl+C to exit (type h() ENTER for help)
    iex(1)>


~~~

## 变换： 转换响应
在hex.pm 搜到一个Erlang 的json库
添加到依赖：
~~~[elixir]
        
          defp deps do
            [
              { :httpoison , "~> 0.4"},
              { :jsx ,        "~> 2.0"}
            ]
          end
~~~
运行
>  mix deps.get
安装jsx

从字符串转换内容
~~~
    
     def handle_response(%{statues_code: 200 , body: body}) ,
      do: { :ok , :jsx.decode(body) }
    
      def handle_response(%{status_code: ____, body: body }),
      do: { :error , :jsx.decode(body) }

~~~
我们需要处理可能的异常响应 ,回退到CLI模块去 ：
~~~
    
     def process({ user , project , _count } ) do
    
           Issues.GithubIssues.fetch(user , project)
    
           |> decode_response
    
          end
    
          def decode_response({:ok, body}) , do: body
    
          def decode_response({:error,  error}) do
            {_,message} =
            List.keyfind(error , "message" , 0)
            IO.puts "Error fetching from github: #{message}"
    
            System.halt(2)
          end
~~~
更方便的访问：
~~~
    
      # 转换列表的列表 到哈希字典的列表
          def
          convert_to_list_of_hashdicts(list) do
          list
          |> Enum.map(&Enum.into(&1,HashDict.new))
          end
~~~

### 应用程序配置
硬编码的 url 使其可以从配置文件来做
**config/**  目录

config/config.exs 此文件存储应用程序级别的配置
应该始于  use Mix.Config 
接下来配置：
> config :issues , github_url: "https://api.github.com"

每个配置行添加一个或多个 k v 配置对 到应用程序的 **_environment** 去

可以使用 Application.get_env 函数从（environment）环境中返回一个值
定义为模块的属性（Issues.GithubIssues）
>
     # use a module attribute to fetch the value at compile time 
      @github_url  Application.get_env(:issues,:github_url)
      
可根据环境加载不同的配置 ，我们可以使用import_config 函数来从一个文件读取配置
>  
      import_config  "#{Mix.evn}.exs"

此时Elixir会根据你的环境读取不同的配置： dev.exs , test.exs , 或 prod.exs 
      
      
我们亦可以使用 --config 选项来覆盖默认的config/config.exs 给elixir
      
## 变换： 排序数据
      
在created_at 字段做排序 Elixir标准库中的 sort/2 就可以做     
 
>
      # 排序
          def sort_into_ascending_order(list_of_issues)
          do:
            Enum.sort list_of_issues , fn i1, i2 -> i1["created_at"] <= i2["created_at"] end
          end

## 变换： 采用最先的第n项

不用写额外的函数了 用内置的Enum.take 方法就可以做到          
      


