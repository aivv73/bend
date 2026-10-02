import Base

def index(+width: U32, x: U32, y: U32) -> U32:
  U32.add(U32.mul(y, width), x)

def inside(+width: U32, +height: U32, x: U32, y: U32) -> Bool:
  U32.is_lt(x, width) && U32.is_lt(y, height)

def printed_last(r: Array<U32> & U32) -> IO(Unit):
  (pixels, color) = r
  IO.print("last RGB word = " ++ U32.show(color))

def printed_first(+width: U32, +height: U32, r: Array<U32> & U32) -> IO(Unit):
  (pixels, color) = r
  do IO<Unit>:
    IO.print("first RGB word = " ++ U32.show(color))
    printed_last(Array.get(U32, pixels,
      index(width, U32.sub(width, 1), U32.sub(height, 1))))

def closed(capture: Capture, unit: Unit) -> IO(Unit):
  Capture{+width, +height, pixels} = capture
  do IO<Unit>:
    IO.print(U32.show(width) ++ "x" ++ U32.show(height))
    printed_first(width, height, Array.get(U32, pixels, 0))

def captured(q: Window & Result<&1, &1, U32 & String, Capture>) -> IO(Unit):
  (window, result) = q
  match result:
    case Done{capture}:
      IO.bind(Unit, Unit, Window.close(window), closed(capture))
    case Fail{(code, message)}:
      do IO<Unit>:
        Window.close(window)
        IO.print("capture error " ++ U32.show(code) ++ " " ++ message)

def framed(q: Window & Image & List<Event>) -> IO(Unit):
  (window, image, events) = q
  IO.bind(Window & Result<&1, &1, U32 & String, Capture>, Unit,
    Window.capture(window), captured)

def opened(result: Result<&1, &1, U32 & String, Window>) -> IO(Unit):
  match result:
    case Done{window}:
      do IO<Unit>:
        IO.sleep(250)
        IO.bind(Window & Image & List<Event>, Unit,
          Window.frame(window, Qua{Pix{16711680}, Pix{65280}, Pix{255}, Pix{16777215}}),
          framed)
    case Fail{(code, message)}:
      IO.print("open error " ++ U32.show(code) ++ " " ++ message)

def main() -> IO(Unit):
  IO.bind(Result<&1, &1, U32 & String, Window>, Unit,
    Window.open("Bend client capture", 641, 513), opened)
