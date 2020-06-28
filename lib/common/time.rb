def with_time(&_block)
  start = Process.clock_gettime Process::CLOCK_MONOTONIC
  data  = yield
  time  = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start

  [data, time]
end
