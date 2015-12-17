defmodule Sequence.Server do
  @moduledoc false

  use GenServer

  def handle_call(:next_number , _form , current_number) do
    { :reply , current_number , current_number+1 }
  end

 def handle_call({:set_nuber , new_nuber} , _from , _current_number)  do
        {:reply , new_number,new_number }
 end


    def handle_call({:factors , number} , _, _ ) do
        {:reply , { :factors_of , number , factors(number) } , [] }
    end

  def handle_cast({ :increment_number , delta } , current_nuber ) do
    { :noreply , current_number + delta }
  end
end