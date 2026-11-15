import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// share_plus falls back to a `mailto:` link when the browser has no Web
/// Share API (desktop Firefox, for one); there we copy instead.
bool get hasNativeShare {
  final navigator = globalContext.getProperty<JSObject?>('navigator'.toJS);
  return navigator != null && navigator.has('share');
}
