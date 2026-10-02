function capturetest_change(window, mode) {
  return io_tup(window, {$: CID(False)});
}

io_eff(CID(CaptureTest.change), capturetest_change);
