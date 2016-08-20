use "collections"
use "promises"
use "term"
use "time"

actor PonyBench
  embed _bs: Array[(String, {()} val, String)]
  let _env: Env

  new create(env: Env) =>
    (_bs, _env) = (Array[(String, {()} val, String)], env)

  be apply[A: Any #share](name: String, f: {(): A ?} val, ops: U64 = 0) =>
    let bf = recover val
      if ops == 0 then
        lambda()(notify = this, name, f) =>
          _AutoBench[A](notify, name, f)()
        end
      else
        lambda()(notify = this, name, f, ops) =>
          _Bench[A](notify)(name, f, ops)
        end
      end
    end
    _bs.push((name, bf, ""))
    if _bs.size() < 2 then bf() end

  be async[A: Any #share](
    name: String,
    f: {(): Promise[A] ?} val,
    timeout: U64 = 0,
    ops: U64 = 0
  ) =>
    if timeout > 0 then
      let t = Timer(object iso is TimerNotify
        let _bench: PonyBench = this
        let _name: String = name
        let _f: {(): Promise[A] ?} val = f
        let _ops: U64 = ops
        fun ref apply(timer: Timer ref, count: U64): Bool =>
          _bench._failure(_name)
          false
        fun ref cancel(timer: Timer ref) =>
          _bench.async[A](_name, _f, 0, _ops)
      end, timeout)
      let ts = Timers
      let tt: Timer tag = t
      ts(consume t)
      try
        let p = f()
        p.next[A](recover
          lambda(a: A)(ts, tt): A =>
            ts.cancel(tt)
            a
          end
        end)
      else
        _failure(name)
      end
    end

    let bf = recover val
      if ops == 0 then
        lambda()(notify = this, name, f) =>
          _AutoBench[A](notify, name, f)()
        end
      else
        lambda()(notify = this, name, f, ops) =>
          _BenchAsync[A](notify)(name, f, ops)
        end
      end
    end
    _bs.push((name, bf, ""))
    if _bs.size() < 2 then bf() end

  be _result(name: String, ops: U64, nspo: U64) =>
    let fmt = FormatSettingsInt.set_width(10)
    let sl = [name, "\t", ops.string(fmt), "\t", nspo.string(fmt), " ns/op"]
    _update(name, String.join(sl))
    _next()

  be _failure(name: String) =>
    let sl = [ANSI.red(), "**** FAILED Benchmark: ", name, ANSI.reset()]
    _update(name, String.join(sl))
    _next()

  fun ref _update(name: String, result: String) =>
    try
      for (i, (n, f, s)) in _bs.pairs() do
        if n == name then
          _bs(i) = (n, f, result)
        end
      end
    end

  fun ref _next() =>
    try
      while _bs(0)._3 != "" do
        _env.out.print(_bs.shift()._3)
      end
      if _bs.size() > 0 then
        _bs(0)._2()
      end
    end

interface tag _BenchNotify
  be _result(name: String, ops: U64, nspo: U64)
  be _failure(name: String)
