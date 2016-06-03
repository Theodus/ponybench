use "time"
use "collections"
use "debug"

class BenchmarkRunner
  """
  Manages the aggregation of benchmark resuls and provides functions for
  managing the timer and discarding results.
  """
  let _env: Env
  var _bench_time: U64
  var _n: USize = 1
  var _start_time: U64 = 0
  var _duration: U64 = 0
  var _timing: Bool = false
  var _prev_n: USize = 0
  var _prev_duration: U64 = 0

  new _create(env: Env, benchtime: U64 = 1_000_000_000) =>
    _env = env
    _bench_time = benchtime

  fun ref apply(bench: Benchmark) ? =>
    """
    Run the given benchmark.
    """
    _reset()
    _run(bench)
    while (_duration < _bench_time) and (_n < 1_000_000_000) do
      let nspo = _ns_per_op()
      _n = if nspo == 0 then
        1_000_000_000
      else
        (_bench_time / nspo).usize()
      end
      _n = _max(_min(_n + (_n / 5), _prev_n * 100), _prev_n + 1)
      _n = _round_up(_n)
      _run(bench)
    end
    _result(bench.name())

  fun ref start_timer() =>
    """
    Start timing a benchmark. This function is called automatically before a
    benchmark starts, but it can also be used to resume timing after a call to
    stop_timer.
    """
    if not _timing then
      _start_time = Time.nanos()
      _timing = true
    end

  fun ref stop_timer() =>
    """
    Stop timing a benchmark. This function can be used to pause the timer while
    performing complex initialization that you don't want to measure.
    """
    if _timing then
      _duration = _duration + (Time.nanos() - _start_time)
      _timing = false
    end

  fun ref reset_timer() =>
    """
    Zero the elapsed benchmark time, does not affect whether the timer is
    running.
    """
    if _timing then
      _start_time = Time.nanos()
    end
    _duration = 0

  fun n(): USize =>
    """
    Number of iterations to execute the benchmark.
    """
    _n

  fun discard(v: Stringable) =>
    """
    Avoid loop optimization by calling this function in the benchmark loop.
    """
    if not Platform.debug() then
      Debug.out(v.string())
    end

  fun ref _run(bench: Benchmark) ? =>
    reset_timer()
    start_timer()
    bench(this)
    stop_timer()
    _prev_n = _n
    _prev_duration = _duration

  fun _ns_per_op(): U64 =>
    if _n <= 0 then
      0
    else
      _duration / _n.u64()
    end

  fun _min(x: USize, y: USize): USize =>
    if x > y then y else x end

  fun _max(x: USize, y: USize): USize =>
    if x > y then x else y end

  fun _round_down_10(x: USize): USize =>
    """
    Round down to the nearest power of 10.
    """
    var tens: USize = 0
    // tens = floor(log_10(n))
    var x' = x
    while x' >= 10 do
      x' = x' / 10
      tens = tens + 1
    end
    // result = 10^tens
    var result: USize = 1
    for i in Range[USize](0, tens) do
      result = result * 10
    end
    result

  fun _round_up(x: USize): USize =>
    """
    Round x up to a number of the form [1ex, 2ex, 3ex, 5ex].
    """
    let base = _round_down_10(x)
    if x <= base then
      base
    elseif x <= (base * 2) then
      base * 2
    elseif x <= (base * 3) then
      base * 3
    elseif x <= (base * 5) then
      base * 5
    else
      base * 10
    end

  fun ref _reset() =>
    _n = 1
    _start_time = 0
    _duration = 0
    _timing = false
    _prev_n = 0
    _prev_duration = 0

  fun _result(name: String) =>
    let fmt = FormatSettingsInt.set_width(10)
    let list = recover Array[String](6) end
    list.push(name)
    list.push("\t")
    list.push(_n.string(fmt))
    list.push("\t")
    list.push(_ns_per_op().string(fmt))
    list.push(" ns/op\n")
    _env.out.writev(consume list)
