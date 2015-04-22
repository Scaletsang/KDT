# path to app
@dir = "##path##"

worker_processes 2
working_directory @dir

timeout 30

# path to socket unicorn listens to
listen "#{@dir}/tmp/sockets/unicorn.sock", :backlog => 64

# process id path
pid "#{@dir}/tmp/pids/unicorn.pid"

# log file paths
stderr_path "#{@dir}/log/unicorn.stderr.log"
stdout_path "#{@dir}/log/unicorn.stdout.log"
