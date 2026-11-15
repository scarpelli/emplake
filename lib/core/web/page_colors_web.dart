import 'dart:js_interop';
import 'dart:js_interop_unsafe';

String? _last;

void applyPageColors(String iconHref, String background, bool dark) {
  final key = '$iconHref|$background|$dark';
  if (key == _last) return;
  _last = key;
  final document = globalContext.getProperty<JSObject?>('document'.toJS);
  if (document == null) return;
  JSObject? find(String selector) => document.callMethod<JSObject?>('querySelector'.toJS, selector.toJS);
  void paint(JSObject? element) {
    final style = element?.getProperty<JSObject?>('style'.toJS);
    style?.setProperty('background'.toJS, background.toJS);
    style?.setProperty('colorScheme'.toJS, (dark ? 'dark' : 'light').toJS);
  }

  final link = find('link[rel="icon"]');
  link?.setProperty('type'.toJS, 'image/svg+xml'.toJS);
  link?.setProperty('href'.toJS, iconHref.toJS);
  find('meta[name="theme-color"]')?.setProperty('content'.toJS, background.toJS);
  paint(document.getProperty<JSObject?>('documentElement'.toJS));
  paint(document.getProperty<JSObject?>('body'.toJS));
}
