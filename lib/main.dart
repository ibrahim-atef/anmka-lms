import 'package:flutter/material.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

void main() {
  runApp(const AnmkaLmsApp());
}

class AnmkaLmsApp extends StatelessWidget {
  const AnmkaLmsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anmka LMS',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff101010) ,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/logo.png', width: 200, height: 200),
            const SizedBox(height: 30),
            const Text(
              'Anmka Lms',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late WebViewXController _controller;
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;

  // URLs to try
  final List<String> _urls = [
    'https://lmsdemo3.anmka.com',
    'http://lmsdemo3.anmka.com',
    'https://www.lmsdemo3.anmka.com',
    'http://www.lmsdemo3.anmka.com',
  ];

  Future<void> _loadInitialUrl() async {
    for (var url in _urls) {
      try {
        await _controller.loadContent(
          url,

        );
        return; // success
      } catch (e) {
        debugPrint('Failed to load $url: $e');
      }
    }
    setState(() {
      isLoading = false;
      hasError = true;
      errorMessage =
      'All URL attempts failed.\nPlease check your network and try again.';
    });
  }

  Future<void> _reload() async {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = null;
    });
    try {
      await _controller.reload();
    } catch (_) {
      await _loadInitialUrl();
    }
  }

  Future<bool> _onWillPop() async {
    try {
      if (await _controller.canGoBack()) {
        await _controller.goBack();
        return false;
      }
    } catch (_) {}
    return await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد الخروج'),
        content: const Text('هل تريد الخروج من التطبيق؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('خروج'),
          ),
        ],
      ),
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final userAgent =
        'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Positioned.fill(top: 20  ,
              child: WebViewX(
                initialContent: _urls.first,
                initialSourceType: SourceType.url,
                javascriptMode: JavascriptMode.unrestricted,
                userAgent: userAgent,
                onWebViewCreated: (controller) {
                  _controller = controller;
                  _loadInitialUrl();
                },
                onPageStarted: (src) {
                  setState(() {
                    isLoading = true;
                    hasError = false;
                    errorMessage = null;
                  });
                  debugPrint('Page started: $src');
                },
                onPageFinished: (src) {
                  setState(() => isLoading = false);
                  debugPrint('Page finished: $src');
                },
                onWebResourceError: (err) {
                  debugPrint('Resource error: ${err.description}');
                  setState(() {
                    isLoading = false;
                    hasError = true;
                    errorMessage = 'Error: ${err.description}';
                  });
                }, width:  MediaQuery.of(context).size.width,
                height:  MediaQuery.of(context).size.height,
              ),
            ),

            if (isLoading)
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'جاري التحميل...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),

            // if (hasError||errorMessage!=null)
            //   Center(
            //     child: Column(
            //       mainAxisSize: MainAxisSize.min,
            //       children: [
            //         const Icon(Icons.error_outline, size: 64, color: Colors.red),
            //         const SizedBox(height: 16),
            //         Text(
            //           errorMessage ?? 'An unknown error occurred.',
            //           style: const TextStyle(color: Colors.white),
            //           textAlign: TextAlign.center,
            //         ),
            //         const SizedBox(height: 16),
            //         ElevatedButton(
            //           onPressed: _reload,
            //           child: const Text('إعادة المحاولة'),
            //         ),
            //       ],
            //     ),
            //   ),
          ],
        ),

      ),
    );
  }
}