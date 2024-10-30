import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

class JsonRpcWebView extends StatefulWidget {
  const JsonRpcWebView({Key? key}) : super(key: key);

  @override
  JsonRpcWebViewState createState() => JsonRpcWebViewState();
}

class JsonRpcWebViewState extends State<JsonRpcWebView> {
  late final WebViewController _controller;
  DateTime? _webViewLoadStartTime;
  DateTime? _rpcRequestStartTime;

  // Map to store completers for each RPC call
  final Map<int, Completer<String>> _rpcCompleters = {};
  int _currentCallId = 1; // Internal call ID manager

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    _webViewLoadStartTime = DateTime.now();
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            final loadDuration =
                DateTime.now().difference(_webViewLoadStartTime!);
            debugPrint(
                'Page finished loading: $url in ${loadDuration.inMilliseconds} ms');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint(
                'Page resource error: code: ${error.errorCode}, description: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          final jsonMessage = jsonDecode(message.message);
          final id = jsonMessage['id'];

          debugPrint('Received message: $jsonMessage');

          if (jsonMessage['body']['type'] == 'LOG') {
            debugPrint(jsonMessage['body']['message']);
          }

          if (_rpcCompleters.containsKey(id)) {
            _rpcCompleters[id]?.complete(message.message);
            _rpcCompleters.remove(id);
          }
        },
      );

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
    _loadLocalHtml();
  }

  Future<void> _loadLocalHtml() async {
    const runLocal = false;

    if (runLocal) {
      // TODO: Configure env variables for doing that
      _controller
          .loadRequest(Uri.parse("http://192.168.1.117:3000/index.html"));
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final targetDir = Directory('${directory.path}/dock-sdk');

      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      final assetManifest = await rootBundle.loadString('AssetManifest.json');
      final assets = Map<String, dynamic>.from(json.decode(assetManifest));

      // Copy assets while maintaining the directory structure.
      for (final asset in assets.keys) {
        if (asset.startsWith('assets/dock-sdk/')) {
          final data = await rootBundle.load(asset);
          final bytes = data.buffer.asUint8List();

          // Ensure correct directory structure
          final subPath = asset.replaceFirst('assets/dock-sdk/', '');
          final filePath = '${targetDir.path}/$subPath';
          final fileDir =
              Directory(filePath.substring(0, filePath.lastIndexOf('/')));
          if (!await fileDir.exists()) {
            await fileDir.create(recursive: true);
          }
          final file = File(filePath);
          await file.writeAsBytes(bytes, flush: true);
        }
      }

      final indexPath = '${targetDir.path}/index.html';
      _controller.loadFile(indexPath);
    }
  }

  Future<Map<String, dynamic>> sendRpcMessage(
      String method, Map<String, dynamic> args) async {
    _rpcRequestStartTime = DateTime.now();
    final int id = _currentCallId++;

    final completer = Completer<String>();
    _rpcCompleters[id] = completer;

    final jsonRpcRequest = _generateJsonRpcRequest(method, args, id);
    final script = 'window.postMessage(${jsonEncode(jsonRpcRequest)}, "*");';
    _controller.runJavaScript(script);

    final response = await completer.future;
    return jsonDecode(response);
  }

  String _generateJsonRpcRequest(
      String method, Map<String, dynamic> params, int id) {
    final request = {
      "type": "json-rpc-request",
      "jsonrpc": "2.0",
      "id": id,
      "body": {
        "method": method,
        "params": params,
      }
    };
    return jsonEncode(request);
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
