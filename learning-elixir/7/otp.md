OTP
=======
OTP(���ű���ƽ̨ Open Telecom Platform) �Ǹ���� ��ԭ����Erlang������ΪErlang��һ���֣���Ҫ���������硣
�Ѿ�����������չ��ͨ��Ŀ�ĵĿ� ��������Erlang�� ��Ҫ��Elixir����

OTP�ṩ��һЩ������˼���ԭ���������ǵĽ��� ָ������ʻ����ȷ�ķ���
����OTPӦ�ó��򣬣����̣�supervision����������̣��¼����̺�������̡�

## Applications ����

���Erlang/Elixir �еĸ��Ҫ����  ���ܸ�������ⲻһ�� ������ Erlang ���� �� OS���� �Ͳ�һ����
ͬ��������ҲҪС��applications���

����OTP��applications���԰����Ľ����� �����ڶ���Ŀ�ģ������������Է�װwrap�����OTP��applicationsһ����Ϊһ���µģ�super��
һ���Ľ��̡��������applications ��� ���壬��ʼ����������͵��ɽ���supervision������ɣ�����ⳣ��OTPӦ����Щϸ�ڲ�����
����ġ�

applications �� OTP Applications �Ĳ���Ǹ���������ص�

һ���Ǻŵ�OTP Application �����Ӿ��� �ù���ε� iex 
>
    iex(5)> Process.list
    [#PID<0.0.0>, #PID<0.3.0>, #PID<0.6.0>, #PID<0.7.0>, #PID<0.9.0>, #PID<0.10.0>,
     #PID<0.11.0>, #PID<0.12.0>, #PID<0.13.0>, #PID<0.14.0>, #PID<0.15.0>,
     #PID<0.16.0>, #PID<0.17.0>, #PID<0.18.0>, #PID<0.19.0>, #PID<0.20.0>,
     #PID<0.21.0>, #PID<0.22.0>, #PID<0.23.0>, #PID<0.24.0>, #PID<0.25.0>,
     #PID<0.26.0>, #PID<0.27.0>, #PID<0.31.0>, #PID<0.34.0>, #PID<0.35.0>,
     #PID<0.36.0>, #PID<0.37.0>, #PID<0.38.0>, #PID<0.39.0>, #PID<0.40.0>,
     #PID<0.42.0>, #PID<0.43.0>, #PID<0.44.0>, #PID<0.45.0>, #PID<0.60.0>,
     #PID<0.61.0>, #PID<0.62.0>, #PID<0.63.0>, #PID<0.64.0>, #PID<0.65.0>,
     #PID<0.75.0>, #PID<0.76.0>, #PID<0.77.0>, #PID<0.78.0>, #PID<0.79.0>,
     #PID<0.80.0>, #PID<0.81.0>, #PID<0.82.0>, #PID<0.84.0>, ...]
    iex(6)>

Process.list/0  ���ص�ǰ���еĽ����б�

��Щ���ǲ�ͬ�Ľ���ͨ��iex Application ��һ��ġ������е�����Լ�����OTP applications ��
���磬���ǿ��Կ��� ������ �������� �����Ǽ���һ�������Ựʱ��
>
    iex(6)> :application.which_applications
    [{:workpool, 'workpool', '0.0.1'}, {:logger, 'logger', '1.1.1'},
     {:mix, 'mix', '1.1.1'}, {:iex, 'iex', '1.1.1'}, {:elixir, 'elixir', '1.1.1'},
     {:compiler, 'ERTS  CXC 138 10', '6.0'}, {:stdlib, 'ERTS  CXC 138 10', '2.5'},
     {:kernel, 'ERTS  CXC 138 10', '4.0'}]
    iex(7)>

����:application.which_applicaitons/0 �ķ���ֵ������Ϊ{Application, Description, Vsn}
- ����Application ��Ӧ�õ����� 
- Description ���ַ�����ʽ��Ӧ�����ƻ���һ��Ӧ�õĽ����ı�
- Vsn �Ǳ�����Ӧ�õİ汾��
�� ʲô�б����ص�Ӧ�ã� Erlang����� ��һ������ �Ƚ�������ķ��������� �����Ը����Ѽ��ص�ģ��汾��ú���Ҫ������
 **loaded** �汾�ǵ�ǰ���ڴ��е�Ӧ�ð汾�������������һ���汾�� ��
 
 ��֮��application ��Ϊ һ��������ʵ�� ������ ���� ����ĵ�Ԫ/λ �����뵥Ԫ��������Ǻܶණ������ һ��API�� ���ڲ�ѯһ��
 HTTP �˵�(endpoint) , һ���ֲ�ʽ key-value �洢��iex���� �������κ������뵽���߿����Ķ�����
 
## Gen(eric) behaviours
�����Ǵ���Elixir Ӧ�� ���ǿ���ʹ��OTP�����һЩͨ�õ���Ϊ��
��һ��GenServer��Ϊ��GenEvent �� :gen_fsm ��Ϊ�����е���Щ��Ϊ������� ��һ����ͨ�õ�OTP������Ϊ��

��Щ��Ϊ�Ƴ���һЩ���ǲ��ò�������߷��Ĺ�����������Ϣ������

## Gen(eric) servers
OTP��������һ�������Ľ�����ͼ ���Խ�����Ϣ��������Ϣ�����ͷ��ؽ����ͬ�κ�����������������

**Gen** ��GenServer��ʵ�ʴ���� generic ���� general �����ṩ��ͨ�õ�ϸ�� �����Ľ����Ժ����Ľ������ ����̫���������
�û���
�������ǿ��� ���̵����¼�ѭ�����Ի��������ƣ� �����Ĳ�ͬ������ ������Ӧ����Ϣ �� ��Щ��Ϣ�Ĵ��� �󲿷�����ϸ�ڶ�һ����
�����GenServer ��Ϊ ���ṩ�����ǵġ�

��Ϊһ�����ٿ�ʼ�����ӣ��������´������ǵ�key-value store��Ŀ��
��ʼ���κ�GenServerģ�����Ǽܣ�
~~~

    defmodule KV do
      @moduledoc false
    
      use GenServer
    
      def start_link(opts \\ []) do
        GenServer.start_link(__MODULE__, [], opts)
      end
    
      def init() do
        {:ok, HashDict.new}
      end
    end
~~~
Ϊ�˴���һ��GenServer ���̣����Ƕ����˳����Elixirģ�顣 Ȼ������������ģ�� �����ڿ�ʼʹ���� user GenServer ���������
Elixir �������ڶ����ģ�齫ʹ��GenServer��Ϊ��

������ ���Ƕ�����һЩ ר�ú�������ΪҪ��� ����ʵ��ĳ���ӿ� ��Ҫ��ɷ�����ʵ�֣�
>
    def start_link(opt \\ []) do
        GenServer.start_link(__MODULE__, [] , opts )
    end

��Ч�ȼ� Process.spawn ���� Process.spawn_link ,����ʹ��������GenServerģ��İ����������������ǵĽ��̡�����������������
���ǵĵڶ���������