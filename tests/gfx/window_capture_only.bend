import Base

def captured(q: Window & Result<&1, &1, U32 & String, Capture>) -> IO(Unit):
  (window, result) = q
  Window.close(window)

def absent(window: Maybe<&1, Window>) -> IO(Unit):
  match window:
    case None{}:
      IO.print("no owner to capture")
    case Some{owner}:
      IO.bind(Window & Result<&1, &1, U32 & String, Capture>, Unit,
        Window.capture(owner), captured)

def main() -> IO(Unit):
  absent(None{})

#|no owner to capture
