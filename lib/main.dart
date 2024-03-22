import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlashCards',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'FlashCards App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  List<FlashCard> cards = [];

  FlashCard currentCard = FlashCard('New Card', 'No Content', 0);

  var _textEditingController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 500),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_controller.status != AnimationStatus.forward) {
          if (_isFront) {
            _controller.forward();
          } else {
            _controller.reverse();
          }
          _isFront = !_isFront;
    }
  }

  FlashCard _getNewUncompletedCard() {
    // WORKHERE
    var random = Random();
    FlashCard? c;
    do {
      c = cards[random.nextInt(cards.length)];
    } while (c == null || c.st8 == 1);
    return c;
  }

  void _addNewCard() {
    setState(() {
      FlashCard newCard = FlashCard('New Card', 'No Content', 0);
      currentCard = newCard;
    }); 
  }

  void _editCard(String f, String b, int? state) {
    setState(() {
      currentCard.front = f;
      currentCard.back = b;
      if (state != null) { currentCard.st8 = state; }
      // DEBUG WORKHERE: re-add currentCard to the list?
    });
  }

  void _markCardAsDone() {
    setState(() {
      currentCard.st8 = 1;
      currentCard = _getNewUncompletedCard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: Container(padding: EdgeInsets.all(5), 
          child: IconButton(
            hoverColor: Colors.amber,
            icon: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              _addNewCard();
            }
          )
        ),
        title: Text(widget.title),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        GestureDetector(
          onTap: _flipCard,
          child: Center(
            child: SizedBox(
              width: 300,
              height: 400,
              child: Transform(
                transform: Matrix4.rotationY(_animation.value * pi),
                alignment: Alignment.center,
                child: _isFront ? _buildFront() : _buildBack(),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildFront() {
    _textEditingController.text = currentCard.front;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: _buildCardSide(true),
    );
  }

  Widget _buildBack() {
    _textEditingController.text = currentCard.back;
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(3.14),
      child: _buildCardSide(false),
    );
  }

  Widget _buildCardSide(bool isFront) {
    return Container(
      decoration: BoxDecoration(
        color: (isFront) ? Colors.blue : Colors.green, 
        borderRadius: BorderRadius.circular(10)),
      child: 
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Center(
              child: TextField(
                controller: _textEditingController,
                style: TextStyle(color: Colors.white, fontSize: 24),
                textAlign: TextAlign.center,
                maxLines: 1,
                onSubmitted: (value) {
                  setState(() {
                    if (isFront) {
                      _editCard(value, currentCard.back, null);
                      _textEditingController.text = currentCard.front;
                    } else {
                      _editCard(currentCard.front, value, null);
                      _textEditingController.text = currentCard.back;
                    }
                  });
                },
              ),
            )),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              IconButton(
                hoverColor: Colors.amber,
                icon: Icon(
                  Icons.check,
                  color: Colors.white,
                ),
                onPressed: () {
                  _markCardAsDone();
                }
              ),
            ])
          ],  
        ),
    );
  }

}



class FlashCard {
  String front = "Blank";
  String back = "This card has not been set.";
  int st8 = 0;

  FlashCard(this.front, this.back, this.st8);
}
