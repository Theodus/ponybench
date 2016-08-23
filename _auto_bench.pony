use "collections"
use "promises"

actor _AutoBench[A: Any #share]
  let _notify: _BenchNotify
  let _run: {(U64)} val
  let _auto_ops: _AutoOps

  new create(
    notify: _BenchNotify,
    name: String,
    f: ({(): A ?} val | {(): Promise[A] ?} val),
    bench_time: U64 = 1_000_000_000,
    max_ops: U64 = 100_000_000
  ) =>
    _notify = notify
    _run = recover
      lambda(ops: U64)(notify = this, name, f) =>
        match f
        | let fn: {(): A ?} val =>
          _Bench[A](notify)(name, fn, ops)
        | let fn: {(): Promise[A] ?} val =>
          _BenchAsync[A](notify)(name, fn, ops)
        end
      end
    end
    _auto_ops = _AutoOps(bench_time, max_ops)

  be apply(ops: U64 = 1) => _run(ops)

  be _result(name: String, ops: U64, nspo: U64) =>
    match _auto_ops(ops, ops*nspo, nspo)
    | let ops': U64 => apply(ops')
    else _notify._result(name, ops, nspo)
    end

  be _failure(name: String) => _notify._failure(name)

class _AutoOps
  let _bench_time: U64
  let _max_ops: U64

  new create(bench_time: U64, max_ops: U64) =>
    (_bench_time, _max_ops) = (bench_time, max_ops)

  fun apply(ops: U64, time: U64, nspo: U64): (U64 | None) =>
    if (time < _bench_time) and (ops < _max_ops) then
      var ops' = if nspo == 0 then
        _max_ops
      else
        _bench_time / nspo
      end
      ops' = (ops' + (ops' / 5)).min(ops * 100).max(ops + 1)
      _round_up(ops')
    else
      None
    end

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
