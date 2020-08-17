import 'dart:developer';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt; // Speech to text recognition algorithm package


// Enable 'virtual microphone uses host input' in the emulator !!!!
// Note: Everything is a widget in Flutter. A widget is just a component of an interface


// Main function for running the app
void main() {
  // runApp function: Inflate the given widget (MyApp() here) and attach it to the screen.
  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  // StatelessWidget is widget that is composed of children i.e. has a build method
  // these widgets DO NOT have a mutable state it needs to track like, changing text in the text box etc.
  @override
  Widget build(BuildContext context) {
    //Material App: A convenience widget that wraps a number of widgets that are commonly required for material design applications.
    return MaterialApp(
      title: 'Speech to Text Recognition',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SpeechView(),
      // home: This is the route that is displayed first when the application is started normally
      // First displaying the SpeechView widget
    );
  }
}



// Type stless or stful for autocomplete Stateless and Stateful widgets respectively

class SpeechView extends StatefulWidget {
  // StatefulWidget: these widgets HAVE a mutable state
  @override
  _SpeechViewState createState() => _SpeechViewState(); // returns a _SpeechViewState widget
  // for fat arrow: https://flutterrdart.com/dart-fat-arrow-or-short-hand-syntax-tutorial/
}

// State widget to execute what happens/changes in SpeechView widget (Stateful widget)
class _SpeechViewState extends State<SpeechView> {

  // Map of words to highlight
  Map<String, HighlightedWord> words = {
    "name": HighlightedWord(
      onTap: () {}, // () {} lets you execute multiple statements.
      textStyle: const TextStyle(color: Colors.pink, fontWeight: FontWeight.bold, fontSize: 36.0,),
    )
  };

  // initializing SpeechToText object
  stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the icon to speak';
  double _confidence = 1.0;

  // Initialize the state of the widget, called only once.
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _speech = stt.SpeechToText(); //set speech to instance of SpeechToText
    setState(() => {_isListening = false});
  }

  // Build the Stateful Widget
  @override
  Widget build(BuildContext context) {
    return Scaffold( // Implements the basic material design visual layout structure.
      appBar: AppBar(
        title: Text('Prediction Confidence: ${(_confidence*100).toStringAsFixed(1)}%'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Colors.deepOrange,
        endRadius: 100.0,
        duration: const Duration(milliseconds: 2000),
        repeatPauseDuration: const Duration(milliseconds: 100),
        repeat: true,
        child: FloatingActionButton(
            onPressed: _listen, // no need of brackets
            child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
      body: SingleChildScrollView(//where text is written is scrollable
        reverse: true,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 108.0),
          child: TextHighlight(text: _text, words: words, textStyle: const TextStyle(
            fontSize: 30.0,
            color: Colors.black,
            fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  // listen method that is part of the State class for the Stateful widget. Note that this method is within State Class
  void _listen() async{ // async is a way of telling dart that you plan on using await keyword in the function
    if (!_isListening){
      // check if not listening then initialize speech recognition services
      bool available = await _speech.initialize( // wait for the event
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      // if speech recognition services are available
      if (available){
        // change state to show that app is listening
        // setState sets the state of the widget and triggers update to the UI
        setState(() => {_isListening = true});
        // start listening session
        _speech.listen(
          // onResult is triggered whenever new words are spoken, val is the words
          // onResult change the state via setState
            onResult: (val) => setState((){
              _text = val.recognizedWords; // set text to recognized words
              if (val.hasConfidenceRating && val.confidence >0){
                _confidence = val.confidence; // set confidence values
              }
            }),
          //listenFor: Duration(minutes: 10),
          cancelOnError: false,
          partialResults: true
        );
      }
    } else{
      setState(() => {_isListening = false});
      _speech.stop();
    }
  }
}




