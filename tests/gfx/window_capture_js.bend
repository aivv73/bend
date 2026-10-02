import Base

def CaptureTest.make() -> IO(Window):
  import "./window_capture_js.js"

def CaptureTest.same(window: Window) -> IO(Window & Bool):
  import "./window_capture_js.js"

def report(ok: Bool) -> IO(Unit):
  match ok:
    case True{}:
      IO.print("capture ENOTSUP and same owner")
    case False{}:
      IO.print("bad capture")

def checked(ok: Bool, q: Window & Bool) -> IO(Unit):
  (window, same) = q
  do IO<Unit>:
    Window.close(window)
    report(ok && same)

def captured(q: Window & Result<&1, &1, U32 & String, Capture>) -> IO(Unit):
  (window, result) = q
  match result:
    case Fail{(+code, text)}:
      ok = (U32.is_eq(code, 45) || U32.is_eq(code, 95))
        && String.eq(text,
          "Window.capture: client capture is unavailable on this backend")
      IO.bind(Window & Bool, Unit, CaptureTest.same(window), checked(ok))
    case Done{capture}:
      do IO<Unit>:
        Window.close(window)
        IO.print("unexpected native capture")

def main() -> IO(Unit):
  do IO<Unit>:
    window : Window <- CaptureTest.make()
    IO.bind(Window & Result<&1, &1, U32 & String, Capture>, Unit,
      Window.capture(window), captured)

#|capture ENOTSUP and same owner
