# Set the working application directory
# working_directory "/path/to/your/app"
wd = "/root/appointments_api"
working_directory "/root/appointments_api"

# Unicorn PID file location
# pid "/path/to/pids/unicorn.pid"
pid wd + "/pids/unicorn.pid"

# Path to logs
# stderr_path "/path/to/logs/unicorn.log"
# stdout_path "/path/to/logs/unicorn.log"
stderr_path wd + "/logs/unicorn.log"
stdout_path wd + "/logs/unicorn.log"

# Unicorn socket
# listen "/tmp/unicorn.[app name].sock"
listen "/tmp/unicorn.appointmentsapi.sock"

# Number of processes
# worker_processes 4
worker_processes 2

# Time-out
timeout 30
