import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.deepPurple,
      title: 'Random Quote App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212), // Deep dark background
        primaryColor: const Color(0xFF1E1E1E), // Dark primary color
        colorScheme: ColorScheme.dark(
          primary: Colors.tealAccent,
          secondary: Colors.tealAccent.shade700,
          surface: const Color(0xFF1E1E1E),
        ),
        
      ),
      home: const QuotePage(),
    );
  }
}

class QuotePage extends StatefulWidget {
  const QuotePage({super.key});

  @override
  _QuotePageState createState() => _QuotePageState();
}

class _QuotePageState extends State<QuotePage> {
  String _quote = 'Tap the button to get a random quote';
  String _author = '';
  bool _isLoading = false;
  String _error = '';

  // Replace with your actual Cloudflare Worker endpoint
  final String _apiUrl = 'https://quote-waterfall-1234.bxmedia.workers.dev/';

  Future<void> _fetchRandomQuote() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          _quote = data['quote'] ?? 'No quote found';
          _author = data['author'] ?? 'Unknown';
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load quote');
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch quote. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Random Quotes'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Quote Display
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : _error.isNotEmpty
                        ? Text(
                            _error,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          )
                        : Column(
                            children: [
                              Text(
                                '"$_quote"',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '- $_author',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
              ),

              const SizedBox(height: 30),

              // Fetch Quote Button
              ElevatedButton(
                onPressed: _isLoading ? null : _fetchRandomQuote,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Get Quote'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
