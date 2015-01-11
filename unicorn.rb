worker_processes 3
timeout 15

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Quitting'
    Process.kill 'QUIT', Process.pid
  end
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    # wait for master to send quit
  end
end
