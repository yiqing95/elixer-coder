Transformation : Fetch from gitHub
=================

现在 继续我们的数据转换链 。 把参数解析完后，我们需要转换他们 并从github获取数据。

我们扩展run函数 让其调用一个process 函数 ，给其传递的参数就是parse_ars函数的返回值，我们可以写成这样

>  process( parse_args(arv) )

但为了明白这段代码 ，我们不得不从右往左读！

为了使调用链更明显，可以使用Elixir的管道操作符：

~~~
    
      def run(argv) do
            # process( parse_args(argv) )
            argv
                |> parse_args
                |> process
        end
~~~

我们需要两个process 函数的变体 。
一个处理 用户请求帮助 parse_args 返回:help 的情况
一个处理 用户  项目  数量 返回的情况 。

mix run 可以用下一个Elixir 表达式

##  Task: 任务 使用外部库

如果你来自一个用惯了包管理系统的世界 ，你会对Elixir中没有类似东西而感到失望。

### 寻找库
- 首先 可以在 [elixir-lang](http://elixir-lang.org/docs)找，Elixir的文档，你经常会找到你需要的内置库的。

- 接下来，检查是否有任何标准的Erlang 库做了你需要的事情 。这不是个简单的任务 。
  浏览[erlang doc](http://erlang.org/doc/) 这些库是 顶级分类归排的 。
   
如果你在以上任何一个中找到了你所需的，你可以止步了 。因为这些库已经对你的应用可用了 。但如果你没有找到，你将不得不添加额外
的外部依赖 。

-  下一个要看的地方是 [elixir/Erlang package manager](http://hex.pm) 这是一个小（但不断成长壮大）的库列表 ，可用很好和
mix-based 项目集成到一起 。

如果都失败了，google 和 github 是你的好朋友 。
搜索如 "elixir http client " 或者 "erlang destributed logger" ,很可能你就找到了你需要的库了 。

我们的情况下 ，我们需要一个 Http 客户端 。我们发现Elixir 并没有内置实现 但hex.pm 有一些Http client库。

HTTPPoison 

### 为项目添加库 

Mix 采用这样的做法，所有项目需要的库都应该被拷贝到目录结构中 。  好消息是mix可以为你做这一切 ---- 我们只需要列举出我们的
依赖 ，它会为你完成下面的事情 。

还记得：  mix.exs 这个项目顶级目录下的文件么？
~~~
    
     defp deps do
        [
          { :httppoison , "~> 0.4"}
        ]
      end

~~~
使用 
> mix deps 
列举出所有的依赖和器状态

一旦mix.exs 文件变更 我们就可以使用mix 来管理我们的依赖了。

用 **mix deps.get**来下载依赖
> 
    $ mix deps.get
    ** (Mix) No package with name httppoison (from: mix.exs) in registry
我们拼写错了 包名  修改下 httppoison ==>  httpoison

~~~[shell]

    $ mix deps.get
    ** (Mix) No package with name httppoison (from: mix.exs) in registry
    
    yiqing@yiqing MINGW64 /f/Elixir-workspace/elixer-coder/projects/issues (master)
    $ mix deps.get
    Registry update failed (http_error)
    {:failed_connect, [{:to_address, {'s3.amazonaws.com', 443}}, {:inet, [:inet], :etimedout}]}
    Running dependency resolution
    Dependency resolution completed successfully
      certifi: v0.3.0
      hackney: v1.4.6
      httpoison: v0.8.0
      idna: v1.0.2
      mimerl: v1.0.0
      ssl_verify_hostname: v1.0.5
    * Getting httpoison (Hex package)
    Checking package (https://s3.amazonaws.com/s3.hex.pm/tarballs/httpoison-0.8.0.tar)
    Request failed: {:failed_connect, [{:to_address, {'s3.amazonaws.com', 443}}, {:inet, [:inet], :etimedout}]}
    ** (Mix) Package fetch failed and no cached copy available

~~~
好吧 必须翻墙下载 学个东西都要诅咒下那些造墙与下令使用墙的人（愿你们来世被关在小房子里面！）

打开green （^_^   你懂的）并连接vpn

~~~[shell] 

    $ mix deps.get
    Running dependency resolution
    Dependency resolution completed successfully
      certifi: v0.3.0
      hackney: v1.4.6
      httpoison: v0.8.0
      idna: v1.0.2
      mimerl: v1.0.0
      ssl_verify_hostname: v1.0.5
    * Getting httpoison (Hex package)
    Checking package (https://s3.amazonaws.com/s3.hex.pm/tarballs/httpoison-0.8.0.tar)
    Fetched package
    Unpacked package tarball (c:/Users/Lenovo/.hex/packages/httpoison-0.8.0.tar)
    * Getting hackney (Hex package)
    Checking package (https://s3.amazonaws.com/s3.hex.pm/tarballs/hackney-1.4.6.tar)
    Fetched package
    Unpacked package tarball (c:/Users/Lenovo/.hex/packages/hackney-1.4.6.tar)
    * Getting ssl_verify_hostname (Hex package)
    Checking package (https://s3.amazonaws.com/s3.hex.pm/tarballs/ssl_verify_hostname-1.0.5.tar)
    Fetched package
    Unpacked package tarball (c:/Users/Lenovo/.hex/packages/ssl_verify_hostname-1.0.5.tar)
    * Getting mimerl (Hex package)
    Checking package (https://s3.amazonaws.com/s3.hex.pm/tarballs/mimerl-1.0.0.tar)
    Fetched package
    Unpacked package tarball (c:/Users/Lenovo/.hex/packages/mimerl-1.0.0.tar)
    * Getting idna (Hex package)
    Checking package (https://s3.amazonaws.com/s3.hex.pm/tarballs/idna-1.0.2.tar)
    Fetched package
    Unpacked package tarball (c:/Users/Lenovo/.hex/packages/idna-1.0.2.tar)
    * Getting certifi (Hex package)
    Checking package (https://s3.amazonaws.com/s3.hex.pm/tarballs/certifi-0.3.0.tar)
    Fetched package
    Unpacked package tarball (c:/Users/Lenovo/.hex/packages/certifi-0.3.0.tar)
    
    yiqing@yiqing MINGW64 /f/Elixir-workspace/elixer-coder/projects/issues (master)
    $
~~~
可以看下下载步骤
- 运行依赖解析（dependency resolution）
- 依赖解析成功后  获取依赖（hex 包）
- 检测包 获取包 解压到我们的 **.../.hex/packages/** 目录下
    对依赖列表逐个获取
大致就是上面的过程    
#### 再次运行 mix deps
~~~

    yiqing@yiqing MINGW64 /f/Elixir-workspace/elixer-coder/projects/issues (master)
    $ mix deps
    * idna (Hex package)
      locked at 1.0.2 (idna)
      the dependency build is outdated, please run "mix deps.compile"
    * mimerl (Hex package)
      locked at 1.0.0 (mimerl)
      the dependency build is outdated, please run "mix deps.compile"
    * ssl_verify_hostname (Hex package)
      locked at 1.0.5 (ssl_verify_hostname)
      the dependency build is outdated, please run "mix deps.compile"
    * certifi (Hex package)
      locked at 0.3.0 (certifi)
      the dependency build is outdated, please run "mix deps.compile"
    * hackney (Hex package)
      locked at 1.4.6 (hackney)
      the dependency build is outdated, please run "mix deps.compile"
    * httpoison (Hex package)
      locked at 0.8.0 (httpoison)
      the dependency build is outdated, please run "mix deps.compile"

~~~
看到依赖都被安装了 但没有编译
我们多了 mix.lock 文件，

不必担心库未被编译-- mix 会自动在我们使用他们的第一次时为我们编译的
再次审视我们的项目树，会发现一个新的deps 目录 里面包含了我们的依赖 ，**这些依赖本身也是项目**


