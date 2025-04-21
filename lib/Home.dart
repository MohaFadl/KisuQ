import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff202020),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 1), // Push content from top
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Image.asset('images/KitsuQ.png' , width: 200, height: 200),
              ),
              const SizedBox(height: 20),
              Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _isFocused ? 500 : 250,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(20),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: TextField(
                      focusNode: _focusNode,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search, color: Colors.white70),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
