import Base

def CaptureTest.fixture() -> IO(Capture):
  import "./window_capture_abi.c"
  import "./window_capture_abi.js"

def read(r: Array<U32> & U32) -> U32:
  (pixels, value) = r
  value

def clone_read(pixels: Array<U32>, r: Array<U32> & U32) -> IO(Unit):
  (changed, value) = r
  do IO<Unit>:
    IO.print(U32.show(value))
    IO.print(U32.show(read(Array.get(U32, pixels, 14))))

def cloned(r: Array<U32> & Array<U32>) -> IO(Unit):
  (pixels, clone) = r
  clone_read(pixels, Array.get(U32, Array.set(U32, clone, 14, 42), 14))

def tail(r: Array<U32> & U32) -> IO(Unit):
  (pixels, value) = r
  do IO<Unit>:
    IO.print(U32.show(value))
    cloned(Array.clone(U32, pixels))

def last(r: Array<U32> & U32) -> IO(Unit):
  (pixels, value) = r
  do IO<Unit>:
    IO.print(U32.show(value))
    tail(Array.get(U32, pixels, 15))

def first(r: Array<U32> & U32) -> IO(Unit):
  (pixels, value) = r
  do IO<Unit>:
    IO.print(U32.show(value))
    last(Array.get(U32, pixels, 14))

def sized(r: Array<U32> & U32) -> IO(Unit):
  (pixels, value) = r
  do IO<Unit>:
    IO.print(U32.show(value))
    first(Array.get(U32, pixels, 0))

def checked(capture: Capture) -> IO(Unit):
  Capture{width, height, pixels} = capture
  do IO<Unit>:
    IO.print(U32.show(width) ++ "x" ++ U32.show(height))
    sized(Array.size(U32, pixels))

def main() -> IO(Unit):
  IO.bind(Capture, Unit, CaptureTest.fixture(), checked)

#|5x3
#|16
#|1193046
#|11259375
#|0
#|42
#|11259375
