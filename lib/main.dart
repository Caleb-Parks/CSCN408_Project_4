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

  List<FlashCard> cards_draw = [];
  List<FlashCard> cards_done = [];

  FlashCard currentCard = FlashCard(front:'New Card', back:'No Content', st8:2);

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
    FlashCard? c;
    if(cards_draw.length > 0) {
      var randomI = Random().nextInt(cards_draw.length);
      c = cards_draw.removeAt(randomI);
      /*DEBUG*/print("Removing $c from draw.");
    } else {
      c = FlashCard(front:"No cards to draw.", back:"The draw pile is empty.", st8:2);
    }
    return c;
  }

  FlashCard _getNewCompletedCard() {
    FlashCard? c;
    if(cards_done.length > 0) {
      var randomI = Random().nextInt(cards_done.length);
      c = cards_done.removeAt(randomI);
      /*DEBUG*/print("Removing $c from done.");
    } else {
      c = FlashCard(front:"No cards to draw.", back:"The done pile is empty.", st8:2);
    }
    return c;
  }

  void _addNewCard() {
    setState(() {
      FlashCard newCard = FlashCard(front:'New Card', back:'No Content', st8:2);
      _dismissCurrentCard();
      currentCard = newCard;
    }); 
  }

  void _editCard(String f, String b) {
    setState(() {
      currentCard.front = f;
      currentCard.back = b;
      currentCard.st8 = 0;
    });
  }

  void _dismissCurrentCard() {
    setState(() {
      if (currentCard.st8 == 0) {
        cards_draw.add(currentCard);
        /*DEBUG*/print("Adding currentCard to unfinished cards.");
      } else if (currentCard.st8 == 1) {
        /*DEBUG*/print("Adding currentCard to finished cards.");
        cards_done.add(currentCard);
      } else {
        /*DEBUG*/print("Currentcard state is not 1 or 0, deleting current card.");
      }
    });
  }  

  void _markCardAsDone() {
    setState(() {
      if (currentCard.st8 != 2) currentCard.st8 = 1;
      _dismissAndDrawUncompleted();
      printLists_DEBUG(); // DEBUG
    });
  }

  void _markCardAsUnDone() {
    setState(() {
      if (currentCard.st8 != 2) currentCard.st8 = 0;
      _dismissAndDrawUncompleted();
      printLists_DEBUG(); // DEBUG
    });
  }

  void _dismissAndDrawUncompleted() {
    _dismissCurrentCard();
    currentCard = _getNewUncompletedCard();
  }

  void _dismissAndDrawCompleted() {
    _dismissCurrentCard();
    currentCard = _getNewCompletedCard();
  }

  void _deleteCard () {
    setState(() {
      currentCard = _getNewUncompletedCard();
      printLists_DEBUG(); // DEBUG
    });
  }

  void printLists_DEBUG() { // DEBUG
    print("CurrentCard: $currentCard");
    print("Draw pile:\n");
    print(cards_draw);

    print("Done pile:\n");
    print(cards_done);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: Container(padding: EdgeInsets.all(5), 
          child: IconButton( // Add new card
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
        Expanded(child: 
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
        ),
        
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          IconButton( // Mark done button
            hoverColor: Colors.amber,
            icon: Icon(
              Icons.square,
              color: Colors.grey,
            ),
            tooltip: "Draw from uncompleted cards.",
            onPressed: () {
              _dismissAndDrawUncompleted();
            }
          ),
          Expanded(child: Container()),
          IconButton( // Mark un-done button
            hoverColor: Colors.amber,
            icon: Icon(
              Icons.square,
              color: Colors.black,
            ),
            tooltip: "Draw from completed cards.",
            onPressed: () {
              _dismissAndDrawCompleted();
            }
          ),           
        ])

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
                      _editCard(value, currentCard.back);
                      _textEditingController.text = currentCard.front;
                    } else {
                      _editCard(currentCard.front, value);
                      _textEditingController.text = currentCard.back;
                    }
                  });
                },
              ),
            )),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              IconButton( // Mark done button
                hoverColor: Colors.amber,
                icon: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
                onPressed: () {
                  _deleteCard();
                }
              ),
              Expanded(child: Container()),
              IconButton( // Mark un-done button
                hoverColor: Colors.amber,
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () {
                  _markCardAsUnDone();
                }
              ),
              IconButton( // Mark done button
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
  String front;
  String back;
  int st8; // 0 = not done, 1 = done, 2 = not a real card

  FlashCard({this.front = "Blank", this.back = "This card has not been set.", this.st8 = 0});

  @override
  String toString() {
    return "[f=$front, b=$back, st8=${st8.toString()}]";
  }
}
