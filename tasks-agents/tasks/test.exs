{ :ok , count } = Agent.start(fn -> 0 end )
Agent.get(count , &(&1) )