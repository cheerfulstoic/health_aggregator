defmodule HealthAggregator.Publisher.SFTP do
  def upload(content, filename) do
    root_path = System.get_env("SFTP_ROOT_PATH")
    path = "#{root_path}#{filename}"

    IO.puts("Uploading to #{path}")
    SFTPClient.connect(options(), fn conn ->
      IO.inspect(String.length(content), label: :length)
      target_stream = SFTPClient.stream_file!(conn, path)

      Enum.into([content], target_stream)
      |> Stream.run()
    end)
    IO.puts("Uploaded!")
  end

  defp options do
    [
      host: System.get_env("SFTP_DOMAIN"),
      user: System.get_env("SFTP_USER"),
      password: System.get_env("SFTP_PASSWORD"),
    ]
  end

end
