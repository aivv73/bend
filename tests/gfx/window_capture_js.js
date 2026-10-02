const capture_test_owner = {};

function capturetest_make() {
  return capture_test_owner;
}

function capturetest_same(window) {
  return io_tup(window, { $: window === capture_test_owner ? CID(True) : CID(False) });
}

io_eff(CID(CaptureTest.make), capturetest_make);
io_eff(CID(CaptureTest.same), capturetest_same);
