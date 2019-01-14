 (function () {
  if (navigator.userAgent.match(/(iPad|iPhone|iPod).*?moschat_ios/g)) {
  /**
   *  YYApiCore
   */
  YYApiCore = {
  __GLOBAL_FUNC_INDEX__: 0,
  
  invokeClientMethod: function(module, name, parameters, callback) {
  var url = 'yyapi://' + module + '/' + name + '?p=' + encodeURIComponent(JSON.stringify(parameters || {}));
  if (callback) {
  var name;
  if (typeof callback == "function") {
  name = YYApiCore.createGlobalFuncForCallback(callback);
  } else {
  name = callback;
  }
  
  url = url + '&cb=' + name;
  }
  console.log('[API]' + url);
  window.webkit.messageHandlers.YYWKWebViewAPI.postMessage(url);
  },
  
  createGlobalFuncForCallback: function(callback){
  if (callback) {
  var name = '__GLOBAL_CALLBACK__' + (YYApiCore.__GLOBAL_FUNC_INDEX__++);
  window[name] = function(){
  var args = arguments;
  var func = (typeof callback == "function") ? callback : window[callback];
  //we need to use setimeout here to avoid ui thread being frezzen
  setTimeout(function(){ func.apply(null, args); }, 0);
  };
  return name;
  }
  return null;
  },
  
  invokeWebMethod: function(callback, returnValue) {
  YYApiCore.invokeCallbackWithArgs(callback, [returnValue]);
  },
  
  invokeCallbackWithArgs: function(callback, args) {
  if (callback) {
  var func = null;
  var tmp;
  if (typeof callback == "function") {
  func = callback;
  }
  else if((tmp = window[callback]) && typeof tmp == 'function') {
  func = tmp;
  }
  if (func) {
  setTimeout(function(){ func.apply(null, args); }, 0);
  }
  }
  }
  };
//  var readyEvent = window.document.createEvent('Events')
//  readyEvent.initEvent('WebViewJavascriptBridgeReady')
//  readyEvent.bridge = WebViewJavascriptBridge
//  doc.dispatchEvent(readyEvent)
  }
  }) ();

