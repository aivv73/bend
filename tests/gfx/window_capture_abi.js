function capturetest_fixture() {
  const pixels = new Uint32Array(16);
  pixels[0] = 0x123456;
  pixels[14] = 0xABCDEF;
  return {$: CID(Capture), width: 5, height: 3, pixels};
}

io_eff(CID(CaptureTest.fixture), capturetest_fixture);
