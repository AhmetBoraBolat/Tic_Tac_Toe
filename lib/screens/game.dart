import 'dart:async';
import 'package:flutter/material.dart';

import 'package:tic_tac_toe/constants/colors.dart';
// ignore: depend_on_referenced_packages
import 'package:google_fonts/google_fonts.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool oTurn = true;
  List<String> displayXO = ['', '', '', '', '', '', '', '', ''];

  int oScore = 0, xScore = 0;
  static const maxSeconds = 30;
  int seconds = maxSeconds;
  String resultDeclaration = '';
  Timer? timer;

  static var customFontWhite = GoogleFonts.righteous(
    textStyle: const TextStyle(
      color: Colors.white,
      letterSpacing: 3,
      fontSize: 28,
    ),
  );

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (seconds > 0) {
          seconds--;
        } else {
          stopTimer();
        }
      });
    });
  }

  void stopTimer() {
    resetTimer();
    timer?.cancel();
  }

  void resetTimer() => seconds = maxSeconds;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainColor.primaryColor,
      body: Padding(
        padding: const EdgeInsets.all(35.0),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.only(top: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Player O',
                          style: customFontWhite,
                        ),
                        Text(
                          oScore.toString(),
                          style: customFontWhite,
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Player X',
                          style: customFontWhite,
                        ),
                        Text(
                          xScore.toString(),
                          style: customFontWhite,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              // box board
              flex: 7,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: displayXO.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      if (displayXO[index] == '' && resultDeclaration.isEmpty) {
                        _tapped(index);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(20),
                        border: Border.all(
                          width: 5,
                          color: MainColor.primaryColor,
                        ),
                        color: MainColor.secondaryColor,
                      ),
                      child: Center(
                        child: Text(
                          displayXO[index],
                          style: GoogleFonts.coiny(
                            textStyle: TextStyle(
                              fontSize: 64,
                              color: MainColor.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (resultDeclaration.isNotEmpty)
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        resultDeclaration,
                        style: customFontWhite,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildTimer(),
                  ],
                ),
              ),
            if (resultDeclaration
                .isEmpty) // Eklendi: Timer bitmeden butonu gösterme
              Expanded(
                flex: 2,
                child: _buildTimer(),
              ),
          ],
        ),
      ),
    );
  }

  void _tapped(int index) {
    if (oTurn && timer!.isActive) {
      setState(() {
        displayXO[index] = 'O';
        oTurn = !oTurn;
        _checkWinner();
      });
    } else if (!oTurn && timer!.isActive) {
      setState(() {
        displayXO[index] = 'X';
        oTurn = !oTurn;
        _checkWinner();
      });
    }
  }

  void _checkWinner() {
    List<List<int>> winningCombinations = [
      // Winning combinations
      [0, 1, 2], // 1st row
      [3, 4, 5], // 2nd row
      [6, 7, 8], // 3rd row
      [0, 3, 6], // 1st column
      [1, 4, 7], // 2nd column
      [2, 5, 8], // 3rd column
      [0, 4, 8], // diagonally from top left to bottom right
      [2, 4, 6], // diagonally from top right to bottom left
    ];

    for (var combination in winningCombinations) {
      if (displayXO[combination[0]] != '' &&
          displayXO[combination[0]] == displayXO[combination[1]] &&
          displayXO[combination[0]] == displayXO[combination[2]]) {
        // Winning combination found
        String winner = displayXO[combination[0]];
        setState(() {
          resultDeclaration = 'Player $winner kazandı';
          _updateScore(winner);
          stopTimer(); // Eklendi: Kazanan olduğunda timer'ı durdur
        });
        return;
      }
    }

    // Check if the game is a draw
    if (!displayXO.contains('')) {
      // All cells are full and there is no winner
      setState(() {
        resultDeclaration = 'Oyun berabere bitti';
        stopTimer(); // Eklendi: Oyun berabere bittiğinde timer'ı durdur
      });
    }
  }

  void _updateScore(String winner) {
    if (winner == 'O') {
      oScore++;
    } else if (winner == 'X') {
      xScore++;
    }
  }

  void _resetGame() {
    setState(() {
      oTurn = true;
      displayXO = ['', '', '', '', '', '', '', '', ''];
      resultDeclaration = '';
      startTimer(); // Eklendi: Oyun sıfırlandığında timer'ı yeniden başlat
    });
  }

  Widget _buildTimer() {
    final isRunning = timer == null ? false : timer!.isActive;
    return isRunning
        ? SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: Text(
                    '$seconds',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 50,
                    ),
                  ),
                )
              ],
            ),
          )
        : Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MainColor.secondaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              onPressed:
                  _resetGame, // Değiştirildi: _resetGame metodunu direkt olarak çağır
              child: Text(
                'Play Again!',
                style: customFontWhite,
              ),
            ),
          );
  }
}
