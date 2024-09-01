# LogWisp

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `log_wisp` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:log_wisp, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/log_wisp>.

# LogWisp

**LogWisp** is a universal log streaming and processing tool with powerful extension capabilities in Elixir. It’s designed to be portable, configurable, and efficient, with a user-friendly GUI built using the Phoenix Framework. LogWisp enables real-time log processing, pattern matching, and more, all within a Dockerized environment for easy deployment across different systems.

## Features

- **Universal Log Streaming**: Stream logs from various sources, whether from file systems or remote services.
- **Elixir Extensions**: Leverage Elixir to create custom extensions for handling different log types.
- **Phoenix GUI**: Manage and monitor log streams through an intuitive web interface.
- **Dockerized for Portability**: Easily deploy and run LogWisp on any machine with Docker.
- **Magic Tunnel**: Set up a watcher service on remote Linux systems to act as a log drain, forwarding logs to a LogWisp instance running elsewhere.

## Getting Started

### Prerequisites

- **Docker**: Ensure Docker is installed on your system. [Get Docker](https://www.docker.com/get-started)
- **Elixir**: Required for developing custom log extensions. [Install Elixir](https://elixir-lang.org/install.html)
- **Phoenix Framework**: For the GUI, make sure Phoenix is installed. [Install Phoenix](https://hexdocs.pm/phoenix/installation.html)

### Installation

1. **Clone the Repository**

   ```bash
   git clone https://github.com/otoris/log-wisp.git
   cd log-wisp
   ```

2. **Build and Run the Docker Container**

   ```bash
   docker build -t log-wisp .
   docker run -d -p 4000:4000 log-wisp
   ```

3. **Access the GUI**

   Open your browser and navigate to `http://localhost:4000` to access the LogWisp dashboard.

### Setting Up Log Streaming

#### File System Streaming

1. **Configure Log Source**

   Point LogWisp to your log files by editing the configuration file `config/log_sources.exs`:

   ```elixir
   config :logwisp, LogSources,
     files: [
       "/path/to/log/file1.log",
       "/path/to/log/file2.log"
     ]
   ```

2. **Start Processing**

   Once configured, LogWisp will begin streaming and processing logs automatically.

#### Magic Tunnel Setup (Remote Watcher Service)

If your logs are on a remote machine, you can set up a watcher service to forward logs to your LogWisp Docker instance:

1. **Install Watcher Service**

   Log into the remote machine and install the watcher service:

   ```bash
   curl -o- https://raw.githubusercontent.com/your-username/logwisp/master/install_watcher.sh | bash
   ```

2. **Configure Watcher**

   Edit the `watcher.conf` file to point to your LogWisp instance:

   ```bash
   nano /etc/logwisp/watcher.conf
   ```

   Set the destination to your LogWisp Docker instance’s IP and port:

   ```bash
   destination="http://logwisp-server-ip:4000"
   ```

3. **Start the Watcher**

   Enable and start the service:

   ```bash
   sudo systemctl enable logwisp-watcher
   sudo systemctl start logwisp-watcher
   ```

### Developing Elixir Extensions

1. **Create a New Extension**

   Create a new Elixir module under the `lib/logwisp/extensions/` directory:

   ```elixir
   defmodule LogWisp.Extensions.MyCustomExtension do
     @moduledoc """
     Custom extension for processing specific log patterns.
     """

     def process(log) do
       # Your pattern matching and processing logic here
     end
   end
   ```

2. **Register Your Extension**

   Register your extension in the main LogWisp configuration:

   ```elixir
   config :logwisp, LogWisp.Extensions,
     modules: [
       LogWisp.Extensions.MyCustomExtension
     ]
   ```

3. **Deploy and Test**

   Restart your LogWisp instance to load the new extension and test it with your logs.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request on GitHub.

## License

This project is licensed under the MIT License - see the LICENSE file for details

