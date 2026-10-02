Term capturetest_fixture_run(Env e, Term* f, IoWork* w) {
  u64 pixels = heap_alloc(e, buf_wcls(4));
  memset(e.mem + pixels, 0, 8 * sizeof(u64));
  *blk_ptr(e.mem, pixels, 0) = 0x123456;
  *blk_ptr(e.mem, pixels, 14) = 0xABCDEF;
  u64 out = heap_alloc(e, cls_fit(3));
  e.mem[out] = io_seal(e, 5, CID(Capture));
  e.mem[out + 1] = io_seal(e, 3, CID(Capture));
  e.mem[out + 2] = io_seal(e, term_buf(4, pixels), CID(Capture));
  return term_ctr(CID(Capture), out);
}

static void __attribute__((constructor)) capture_test_abi_use(void) {
  io_eff(CID(CaptureTest.fixture), capturetest_fixture_run, 0);
}
