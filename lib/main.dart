import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart'; // 🎊 Added package

void main() => runApp(const HangmanApp());

class HangmanApp extends StatelessWidget {
  const HangmanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hangman Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Segoe UI',
        useMaterial3: true,
      ),
      home: const HangmanGame(),
    );
  }
}

class HangmanGame extends StatefulWidget {
  const HangmanGame({super.key});

  @override
  State<HangmanGame> createState() => _HangmanGameState();
}

class _HangmanGameState extends State<HangmanGame>
    with SingleTickerProviderStateMixin {
  final List<String> _words = [
    'FLUTTER',
    'DART',
    'WIDGET',
    'ANDROID',
    'STATE',
    'LAYOUT',
    'BUTTON',
    'SCREEN',
    'COLUMN',
    'CONTAINER'
  ];

  late String _wordToGuess;
  Set<String> _guessedLetters = {};
  int _wrongGuesses = 0;
  final int _maxGuesses = 6;
  bool _gameOver = false;
  bool _playerWon = false;

  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late ConfettiController _confettiController; // 🎊

  @override
  void initState() {
    super.initState();

    // ✅ Fix: Initialize controllers first
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));

    _startNewGame();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _startNewGame() {
    setState(() {
      _wordToGuess = _words[Random().nextInt(_words.length)];
      _guessedLetters.clear();
      _wrongGuesses = 0;
      _gameOver = false;
      _playerWon = false;
      _controller.forward(from: 0);
      _confettiController.stop();
    });
  }

  void _guessLetter(String letter) {
    if (_gameOver || _guessedLetters.contains(letter)) return;

    setState(() {
      _guessedLetters.add(letter);

      if (_wordToGuess.contains(letter)) {
        if (_wordToGuess.split('').every((c) => _guessedLetters.contains(c))) {
          _gameOver = true;
          _playerWon = true;
          _confettiController.play(); // 🎊 trigger confetti
        }
      } else {
        _wrongGuesses++;
        if (_wrongGuesses >= _maxGuesses) {
          _gameOver = true;
          _playerWon = false;
        }
      }
    });
  }

  Widget _buildWordDisplay() {
    return Wrap(
      alignment: WrapAlignment.center,
      children: _wordToGuess.split('').map((char) {
        return Container(
          margin: const EdgeInsets.all(6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white, width: 2)),
          ),
          child: Text(
            _guessedLetters.contains(char) ? char : '_',
            style: const TextStyle(
              fontSize: 32,
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLetterButtons() {
    return Wrap(
      alignment: WrapAlignment.center,
      children: List.generate(26, (index) {
        String letter = String.fromCharCode(65 + index);
        bool isGuessed = _guessedLetters.contains(letter);

        return Padding(
          padding: const EdgeInsets.all(3),
          child: ElevatedButton(
            onPressed:
                isGuessed || _gameOver ? null : () => _guessLetter(letter),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isGuessed ? Colors.white24 : Colors.white.withOpacity(0.9),
              foregroundColor: Colors.indigo.shade800,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              minimumSize: const Size(40, 45),
              elevation: isGuessed ? 0 : 3,
            ),
            child: Text(
              letter,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildGameStatus() {
    if (!_gameOver) {
      return Text(
        '❌ Wrong guesses: $_wrongGuesses / $_maxGuesses',
        style: const TextStyle(fontSize: 20, color: Colors.white),
      );
    }

    return FadeTransition(
      opacity: _fadeAnim,
      child: Column(
        children: [
          Text(
            _playerWon ? '🎉 YOU WON!' : '💀 YOU LOST!',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: _playerWon ? Colors.greenAccent : Colors.redAccent,
            ),
          ),
          const SizedBox(height: 10),
          if (!_playerWon)
            Text(
              'Word was: $_wordToGuess',
              style: const TextStyle(fontSize: 22, color: Colors.white70),
            ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _startNewGame,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text('Play Again',
                style: TextStyle(fontSize: 20, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade700,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF4B0082),
                  Color(0xFF6A5ACD),
                  Color(0xFF9370DB)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 🎊 Confetti animation overlay
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            maxBlastForce: 10,
            minBlastForce: 5,
            gravity: 0.3,
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      '🎯 Hangman Challenge 🎯',
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildWordDisplay(),
                    const SizedBox(height: 20),
                    _buildGameStatus(),
                    const SizedBox(height: 30),
                    _buildLetterButtons(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
