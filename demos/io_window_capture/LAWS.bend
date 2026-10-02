import Base
import ./main.bend as Demo

# Runtime contract. Capture reads the owned client's server pixels after output.
# The client must stay fully on-screen and unobscured throughout readback.
# RGB words are 0x00RRGGBB in top-left row-major order, without row padding.
# Width times height is the logical length. The power-of-two capacity tail is zero.
# Success and recoverable failure return the same owner. Capture leaves events queued.
# These native obligations require runtime tests. The laws below cover only arithmetic.

law CaptureDemo.origin:
  {Demo.index(641, 0, 0) == 0 : U32}

law CaptureDemo.last:
  {Demo.index(641, 640, 512) == 328832 : U32}

law CaptureDemo.outside:
  {Demo.inside(641, 513, 641, 0) == False{} : Bool}
