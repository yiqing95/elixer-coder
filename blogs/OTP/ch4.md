这不是你爸爸的应用程序。
-------

因为OTP来自erlang的世界，它使用了erlang的名称来命名事物。不幸的是，这些名称中有一些不不是描述性很好的，application就是一个
例子。我们大部分时间讨论的applications，我们指的是运行的程序做某件事情--- 可能运行在计算机或者手机上，或者通过一个web浏览器。
一个应用程序是一个自包含整体。

但在OTP世界，事情并不是这样的，而是，一个application是一个伴随一个描述符的代码捆绑。描述符告诉运行时这些代码依赖那些东西，
它注册了那些个 全局名称，等。实际上，一个OTP application 更像是一个动态链接库或者一个共享对象 而不是我们通常意义上的程序。

应用是组件，但有一些应用程序位于树的顶端，是用来直接运行的。.

## 进程规范|格 文件
mix 会跟一个 name.app 的文件通讯。name是你应用程序的名称。

这个文件称为application specification ，用来为运行时环境定义应用程序的。Mix 从mix.exs的信息中 自动创建这个文件。

我们的应用程序不需要使用所有的OTP功能 -- 这个文件总是会被创建和引用的 。
然而 一旦你使用了OTP supervision树，添加到mix.exs的东西会被拷贝到.app 文件中。


Hot code-swapping 热码替换
------------

你可能听过OTP应用可用自动更新他们的代码在他们运行的时候。这是真的，实际上任何Elixir程序也可以这么做。OTP提供了一个
release管理框架来处理这件事。

然而这个 OTP release管理 是很复杂的。比如处理在几千个机器上的上万进程间的依赖 （伴随着成千上百的模块）

可以展示给你基本的东西。
首先，真正的不是切换代码，而是切换状态，在一个应用中任何形象都是运行为一个独立的进程的，交换嗲吗简单的只是用一个新的代码
开始一个进程并发送消息给他。然而服务进程维护状态，极可能改变服务的代码会改变他们维护的状态的结构（添加 字段，改变值，或
者其他什么）。所以OTP提供了一个标准的服务回调，允许一个服务从其前一个自己的版本继承状态。

如果我们想版本化自己的代码和数据，我们不得不告诉OTP我们正在运行的东西的版本号。在模块的首部添加@vsn 指令。