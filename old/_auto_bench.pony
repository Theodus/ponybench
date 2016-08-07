use "collections"
use "time"

class _AutoBench[A: Any #share]
  var _bench_time: U64 = 1_000_000_000
  var _n: U64 = 1
  var _start_time: U64 = 0
  var _duration: U64 = 0
  var _timing: Bool = false
  var _prev_n: U64 = 0
  var _prev_duration: U64 = 0
  let _max_ops: U64 = 1_000_000_000

  fun ref apply(f: {(): A ?} val): (U64, U64) ? =>
    _reset()
    _run(f)
    while (_duration < _bench_time) and (_n < _max_ops) do
      _n = if _ns_per_op() == 0 then
        _max_ops
      else
        _bench_time / _ns_per_op()
      end
      _n = _max(_min(_n + (_n / 5), _prev_n * 100), _prev_n + 1)
      _n = _round_up(_n)
      _run(f)
    end
    (_n, _ns_per_op())

  fun ref _start_timer() =>
    if not _timing then
      _start_time = Time.nanos()
      _timing = true
    end

  fun ref _stop_timer() =>
    if _timing then
      _duration = _duration + (Time.nanos() - _start_time)
      _timing = false
    end

  fun ref _reset_timer() =>
    if _timing then
      _start_time = Time.nanos()
    end
    _duration = 0

  fun ref _run(f: {(): A ?} val) ? =>
    @pony_triggergc[None](this)
    _reset_timer()
    _start_timer()
    for i in Range[U64](0, _n) do
      DoNotOptimise[A](f())
    end
    _stop_timer()

    _prev_n = _n
    _prev_duration = _duration

  fun _ns_per_op(): U64 =>
    if _n <= 0 then
      0
    else
      _duration / _n
    end

  fun _min(x: U64, y: U64): U64 =>
    if x > y then y else x end

  fun _max(x: U64, y: U64): U64 =>
    if x > y then x else y end

  fun _round_down_10(x: U64): U64 =>
    """
    Round down to the nearest power of 10.
    """
    var tens: U64 = 0
    // tens = floor(log_10(n))
    var x' = x
    while x' >= 10 do
      x' = x' / 10
      tens = tens + 1
    end
    // result = 10^tens
    var result: U64 = 1
    for i in Range[U64](0, tens) do
      result = result * 10
    end
    result

  fun _round_up(x: U64): U64 =>
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
