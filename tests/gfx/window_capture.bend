import Base

def CaptureTest.change(window: Window, mode: U32) -> IO(Window & Bool):
  import "./window_capture.c"
  import "./window_capture.js"

def report(ok: Bool) -> IO(Unit):
  match ok:
    case True{}:
      IO.print("window capture: OK")
    case False{}:
      IO.print("window capture: FAIL")

def word(r: Array<U32> & U32) -> U32:
  (pixels, value) = r
  value

def fourth(r: Array<U32> & U32) -> Bool:
  (pixels, value) = r
  U32.is_eq(value, 16777215) && U32.is_eq(word(Array.get(U32, pixels, 328833)), 0)

def third(r: Array<U32> & U32) -> Bool:
  (pixels, value) = r
  U32.is_eq(value, 255) && fourth(Array.get(U32, pixels, 328832))

def second(r: Array<U32> & U32) -> Bool:
  (pixels, value) = r
  U32.is_eq(value, 65280) && third(Array.get(U32, pixels, 328192))

def first(r: Array<U32> & U32) -> Bool:
  (pixels, value) = r
  U32.is_eq(value, 16711680) && second(Array.get(U32, pixels, 640))

def inspect_parts(+stage: U32, +width: U32, +height: U32, pixels: Array<U32>) -> Bool:
  match stage:
    case 0:
      U32.is_eq(width, 641) && U32.is_eq(height, 513)
        && first(Array.get(U32, pixels, 0))
    case 1:
      U32.is_eq(width, 641) && U32.is_eq(height, 513)
        && U32.is_eq(word(Array.get(U32, pixels, 5776)), 1267611)
    case 5:
      U32.is_eq(width, 643) && U32.is_eq(height, 515)
        && U32.is_eq(word(Array.get(U32, pixels, 331144)), 1122867)
    case other:
      U32.is_eq(width, 643) && U32.is_eq(height, 515)
        && U32.is_eq(word(Array.get(U32, pixels, 331144)), 11259375)

def inspect(stage: U32, capture: Capture) -> Bool:
  Capture{width, height, pixels} = capture
  inspect_parts(stage, width, height, pixels)

def has_events(events: List<Event>, key: Bool, close: Bool) -> Bool:
  match events:
    case Nil{}:
      key && close
    case Key{97, True{}} <> rest:
      has_events(rest, True{}, close)
    case Close{} <> rest:
      has_events(rest, key, True{})
    case event <> rest:
      has_events(rest, key, close)

def after_close(capture: Capture, ok: Bool, unit: Unit) -> IO(Unit):
  report(ok && inspect(5, capture))

def changed_final(capture: Capture, ok: Bool, q: Window & Bool) -> IO(Unit):
  (window, same) = q
  IO.bind(Unit, Unit, Window.close(window), after_close(capture, ok && same))

def destroyed(capture: Capture, ok: Bool,
  q: Window & Result<&1, &1, U32 & String, Capture>) -> IO(Unit):
  (window, result) = q
  match result:
    case Fail{(code, text)}:
      IO.bind(Window & Bool, Unit, CaptureTest.change(window, 7),
        changed_final(capture, ok && U32.is_eq(code, 2)
          && String.eq(text, "Window.capture: X11 protocol error")))
    case Done{unexpected}:
      do IO<Unit>:
        Window.close(window)
        report(False{})

def changed_destroy(capture: Capture, ok: Bool, q: Window & Bool) -> IO(Unit):
  (window, same) = q
  IO.bind(Window & Result<&1, &1, U32 & String, Capture>, Unit,
    Window.capture(window), destroyed(capture, ok && same))

def retained(capture: Capture, ok: Bool, window: Window) -> IO(Unit):
  IO.bind(Window & Bool, Unit, CaptureTest.change(window, 6),
    changed_destroy(capture, ok))

def failed(window: Window) -> IO(Unit):
  do IO<Unit>:
    Window.close(window)
    report(False{})

def remapped(ok: Bool,
  q: Window & Result<&1, &1, U32 & String, Capture>) -> IO(Unit):
  (window, result) = q
  match result:
    case Done{capture}:
      IO.bind(Window, Unit,
        Window.set_title(window, "Bend capture retained owner"), retained(capture, ok))
    case Fail{error}:
      failed(window)

def changed_remap(ok: Bool, q: Window & Bool) -> IO(Unit):
  (window, same) = q
  IO.bind(Window & Result<&1, &1, U32 & String, Capture>, Unit,
    Window.capture(window), remapped(ok && same))

def unmapped(ok: Bool,
  q: Window & Result<&1, &1, U32 & String, Capture>) -> IO(Unit):
  (window, result) = q
  match result:
    case Fail{(code, text)}:
      IO.bind(Window & Bool, Unit, CaptureTest.change(window, 5),
        changed_remap(ok && U32.is_eq(code, 11) && String.eq(text,
          "Window.capture: client must be viewable and fully on-screen")))
    case Done{capture}:
      failed(window)

def changed_unmap(ok: Bool, q: Window & Bool) -> IO(Unit):
  (window, same) = q
  IO.bind(Window & Result<&1, &1, U32 & String, Capture>, Unit,
    Window.capture(window), unmapped(ok && same))

def events(ok: Bool, q: Window & Image & List<Event>) -> IO(Unit):
  (window, image, input) = q
  IO.bind(Window & Bool, Unit, CaptureTest.change(window, 4),
    changed_unmap(ok && has_events(input, False{}, False{})))

def queued(ok: Bool,
  q: Window & Result<&1, &1, U32 & String, Capture>) -> IO(Unit):
  (window, result) = q
  match result:
    case Done{capture}:
      IO.bind(Window & Image & List<Event>, Unit,
        Window.frame(window, Pix{0}), events(ok && inspect(3, capture)))
    case Fail{error}:
      failed(window)

def changed_queue(ok: Bool, q: Window & Bool) -> IO(Unit):
  (window, same) = q
  IO.bind(Window & Result<&1, &1, U32 & String, Capture>, Unit,
    Window.capture(window), queued(ok && same))

def resized(ok: Bool,
  q: Window & Result<&1, &1, U32 & String, Capture>) -> IO(Unit):
  (window, result) = q
  match result:
    case Done{capture}:
      IO.bind(Window & Bool, Unit, CaptureTest.change(window, 3),
        changed_queue(ok && inspect(2, capture)))
    case Fail{error}:
      failed(window)

def changed_resize(ok: Bool, q: Window & Bool) -> IO(Unit):
  (window, same) = q
  IO.bind(Window & Result<&1, &1, U32 & String, Capture>, Unit,
    Window.capture(window), resized(ok && same))

def mutated(ok: Bool,
  q: Window & Result<&1, &1, U32 & String, Capture>) -> IO(Unit):
  (window, result) = q
  match result:
    case Done{capture}:
      IO.bind(Window & Bool, Unit, CaptureTest.change(window, 2),
        changed_resize(ok && inspect(1, capture)))
    case Fail{error}:
      failed(window)

def changed_mutate(ok: Bool, q: Window & Bool) -> IO(Unit):
  (window, same) = q
  IO.bind(Window & Result<&1, &1, U32 & String, Capture>, Unit,
    Window.capture(window), mutated(ok && same))

def captured(ok: Bool,
  q: Window & Result<&1, &1, U32 & String, Capture>) -> IO(Unit):
  (window, result) = q
  match result:
    case Done{capture}:
      IO.bind(Window & Bool, Unit, CaptureTest.change(window, 1),
        changed_mutate(ok && inspect(0, capture)))
    case Fail{(+code, text)}:
      do IO<Unit>:
        Window.close(window)
        report(ok && (U32.is_eq(code, 45) || U32.is_eq(code, 95))
          && String.eq(text, "Window.capture: client capture is unavailable on this backend"))

def framed(ok: Bool, q: Window & Image & List<Event>) -> IO(Unit):
  (window, image, input) = q
  IO.bind(Window & Result<&1, &1, U32 & String, Capture>, Unit,
    Window.capture(window), captured(ok))

def prepared(q: Window & Bool) -> IO(Unit):
  (window, ok) = q
  IO.bind(Window & Image & List<Event>, Unit,
    Window.frame(window, Qua{Pix{16711680}, Pix{65280}, Pix{255}, Pix{16777215}}),
    framed(ok))

def opened(result: Result<&1, &1, U32 & String, Window>) -> IO(Unit):
  match result:
    case Done{window}:
      IO.bind(Window & Bool, Unit, CaptureTest.change(window, 0), prepared)
    case Fail{(+code, text)}:
      report((U32.is_eq(code, 45) || U32.is_eq(code, 95)) && String.eq(text,
        "Window.open: no display (build a native binary with bend <file> -o <out> and run it from a desktop session)"))

def main() -> IO(Unit):
  IO.bind(Result<&1, &1, U32 & String, Window>, Unit,
    Window.open("Bend capture test", 641, 513), opened)

#|window capture: OK
