static Term capture_test_handle;

#if defined(__linux__) && !defined(__OBJC__)
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/keysym.h>

static BendWin* capture_test_owner;

static u32 capture_test_errors;

static int capture_test_error(Display* dpy, XErrorEvent* event) {
  capture_test_errors += 1;
  return 0;
}
#endif

Term capturetest_change_run(Env e, Term* f, IoWork* work) {
  if ((u32)f[1] == 0) {
    capture_test_handle = f[0];
  }
  bool ok = f[0] == capture_test_handle;
#if defined(__linux__) && !defined(__OBJC__)
  BendWin* win = (BendWin*)(intptr_t)io_hand_v(f[0]);
  u32 mode = f[1];
  if (mode == 0) {
    capture_test_owner = win;
    XSetErrorHandler(capture_test_error);
  }
  ok = ok && capture_test_errors == 0 && win == capture_test_owner
    && XSetErrorHandler(capture_test_error) == capture_test_error;
  Display* dpy = XOpenDisplay(DisplayString(win->dpy));
  if (dpy == NULL) {
    ok = false;
  } else {
    Window id = win->win;
    if (mode == 0) {
      XSync(win->dpy, False);
      XUnmapWindow(dpy, id);
      XSetWindowAttributes attrs = { .override_redirect = True };
      XChangeWindowAttributes(dpy, id, CWOverrideRedirect, &attrs);
      XSizeHints hints = { .flags = 0 };
      XSetWMNormalHints(dpy, id, &hints);
      XMoveResizeWindow(dpy, id, 100, 100, 641, 513);
      XMapWindow(dpy, id);
    } else if (mode == 1) {
      GC gc = XCreateGC(dpy, id, 0, NULL);
      XSetForeground(dpy, gc, 0x13579B);
      XDrawPoint(dpy, id, gc, 7, 9);
      XFreeGC(dpy, gc);
    } else if (mode == 2 || mode == 5) {
      if (mode == 2) {
        XResizeWindow(dpy, id, 643, 515);
      } else {
        XMapWindow(dpy, id);
      }
      GC gc = XCreateGC(dpy, id, 0, NULL);
      XSetForeground(dpy, gc, mode == 2 ? 0xABCDEF : 0x112233);
      XFillRectangle(dpy, id, gc, 0, 0, 643, 515);
      XFreeGC(dpy, gc);
    } else if (mode == 3) {
      XEvent key = {0};
      key.xkey.type = KeyPress;
      key.xkey.display = dpy;
      key.xkey.window = id;
      key.xkey.root = DefaultRootWindow(dpy);
      key.xkey.keycode = XKeysymToKeycode(dpy, XK_a);
      key.xkey.same_screen = True;
      ok = ok && XSendEvent(dpy, id, False, KeyPressMask, &key);
      XEvent close = {0};
      close.xclient.type = ClientMessage;
      close.xclient.window = id;
      close.xclient.message_type = XInternAtom(dpy, "WM_PROTOCOLS", False);
      close.xclient.format = 32;
      close.xclient.data.l[0] = XInternAtom(dpy, "WM_DELETE_WINDOW", False);
      ok = ok && XSendEvent(dpy, id, False, NoEventMask, &close);
    } else if (mode == 4) {
      XUnmapWindow(dpy, id);
    } else if (mode == 6) {
      char* title = NULL;
      ok = ok && XFetchName(dpy, id, &title) && title != NULL
        && strcmp(title, "Bend capture retained owner") == 0;
      if (title != NULL) {
        XFree(title);
      }
      XDestroyWindow(dpy, id);
    }
    XSync(dpy, False);
    XCloseDisplay(dpy);
  }
#endif
  return io_tup(e, f[0], term_pak(ok ? CID(True) : CID(False), 0));
}

static void __attribute__((constructor)) capture_test_use(void) {
  io_eff(CID(CaptureTest.change), capturetest_change_run, 0);
}
