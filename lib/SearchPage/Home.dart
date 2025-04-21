import 'package:flutter/material.dart';
import '../Custom Widgets/KitsuQCustomWidgets.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isAnime = true;
  bool _isRomaji = true;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();

  String searchQuery = "";
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff202020),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'images/KitsuQLogo.png',
                  width: 180,
                  height: 180,
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  KitsuQTitleToggle(
                    isRomaji: _isRomaji,
                    onToggle: () {
                      setState(() {
                        _isRomaji = !_isRomaji;
                      });
                    },
                  ),
                  KitsuQSearchBar(
                    focusNode: _focusNode,
                    controller: _controller,
                    isFocused: _isFocused,
                    onSubmitted: (value) {
                      setState(() {
                        searchQuery = value.trim();
                      });
                    },
                  ),
                  KitsuQMediaToggle(
                    isAnime: _isAnime,
                    onToggle: () {
                      setState(() {
                        _isAnime = !_isAnime;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              if (searchQuery.isNotEmpty)
                KitsuQSearchResults(
                  isRomaji: _isRomaji,
                  isAnime: _isAnime,
                  searchQuery: searchQuery,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
