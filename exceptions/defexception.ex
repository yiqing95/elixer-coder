defmodule KinectProtocalError do
    defexception message: "Kinect protocol error",
                 can_retry: false

    def full_message(me) do
        "Kinect failed #{me.message}, retriable: #{me.can_retry}"
    end
end

try do
    talk_to_kinect
rescue
    error in [KinectProtocolError] ->
        IO.puts KinectProtocolError.full_message(error)
        if error.can_retry, do: schedule_retry
end