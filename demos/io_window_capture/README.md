# Capture your window's client pixels

`Window.capture(window)` returns the same owned Window and a fallible `Capture{width, height, pixels}`. Linux native binaries read the client through X11 after completing earlier output requests. The client must remain fully on-screen and unobscured throughout readback. The border and cursor are excluded. This is a client readback, not a desktop screenshot.

```sh
bend main.bend -o /tmp/bend-client-capture
/tmp/bend-client-capture
```

The example waits 250 ms for initial mapping, renders four quadrant colors, captures once, closes the Window, and reads the independent capture data. The window manager can still change geometry during readback. The example then prints the EAGAIN error. An unobscured 641 by 513 client prints the following values.

```text
641x513
first RGB word = 16711680
last RGB word = 16777215
```

Each U32 pixel has format `0x00RRGGBB`. The origin is at the top left. Index `y * width + x` addresses a logical pixel. Width times height is the logical count, with no row padding. The Array capacity is the smallest power of two that covers that count. Every capacity slot beyond the logical count is zero. `Array.get` wraps its index, so check coordinates against the dimensions before reading.

Capture has no 512 by 512 limit. It queries the actual current client dimensions. The maximum logical count is the existing Array limit of 2^31 pixels. Capture reads only on request and does not add work to `Window.frame`.

X11 TrueColor visuals with disjoint contiguous RGB masks are supported. Channels scale to eight bits with round-to-nearest. Unmapped or off-screen clients, or a detected geometry change during readback, fail with EAGAIN. A missing native window fails with ENOENT. Unsupported visuals and macOS, other native backends, and JavaScript fail with ENOTSUP. Other protocol failures return EINVAL or EIO. Recoverable failures preserve the owner and leave events for the next frame. X11 transport loss and Bend heap exhaustion retain the runtime's fatal policy.

X11 can return undefined obscured pixels without backing store. Capture does not detect occlusion, raise the window, or grab the server. A successful snapshot does not promise an atomic result against arbitrary external changes during readback.

`LAWS.bend` records the runtime contract and pure coordinate laws. `PROOF.bend` proves only those arithmetic laws. Native readback, synchronization, errors, and ownership require runtime tests.

```sh
bend PROOF.bend
bend PROOF.bend --verdict
```
