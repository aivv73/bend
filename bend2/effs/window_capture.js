function window_capture(window) {
  const code = process.platform === "darwin" ? 45 : 95;
  const text = "Window.capture: client capture is unavailable on this backend";
  return io_tup(window, {$: CID(Fail), error: io_tup(code, text)});
}

io_eff(CID(Window.capture), window_capture);
