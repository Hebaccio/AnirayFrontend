import 'package:aniray_desktop/screens/my_home_page.dart';
import 'package:flutter/material.dart';
//import 'package:aniray_desktop/screens/login_screen.dart';

//“Start the Flutter widget tree using MyApp as the root widget.”
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AniRay (Desktop)',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Color.fromARGB(255, 93, 12, 94)),
      ),
      home: const MyHomePage(
        key: ValueKey("login_page"),
        title: 'AniRay (Desktop)',
      ),
    );
  }
}

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//---------------------------------------------------------------------------------------------------------------
//------------------------------------------------KEYS EXPLANATION-----------------------------------------------
//---------------------------------------------------------------------------------------------------------------
//Flutter uses keys to track widgets between UI rebuilds so it doesn’t confuse one widget’s state with another.
//Flutter:
//- Compares old widget tree vs new widget tree
//- Uses keys to identify which widget corresponds to which in the new tree
//- Preserves the correct state of stateful widgets (e.g. TextFields, animations)
//- Avoids reusing the wrong widget in the wrong place
//Without keys it memorises Widgets by position, if widgets change position, it will cause problems
//---------------------------------------------------------------------------------------------------------------


//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//---------------------------------------------------------------------------------------------------------------
//------------------------------------------------OVERRIDE & BUILD-----------------------------------------------
//---------------------------------------------------------------------------------------------------------------
//@override
//Widget build(BuildContext context) {
//StatelessWidget already defines a build() method.
//Override & provide your own implementation.
//Answers the question "What should this widget look like?""
//---------------------------------------------------------------------------------------------------------------


//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//---------------------------------------------------------------------------------------------------------------
//---------------------------------------------------MATERIAL APP------------------------------------------------
//---------------------------------------------------------------------------------------------------------------
//The root framework/configuration widget for a Material Design Flutter app. 
//It can provide navigation/routes, themes, app level config etc.
//---------------------------------------------------------------------------------------------------------------


//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//---------------------------------------------------------------------------------------------------------------
//--------------------------------------------------WIDGET STATES------------------------------------------------
//---------------------------------------------------------------------------------------------------------------
// StatelessWidget (Widget)
// Widget:
//  ├─ Immutable inputs (Final fields)
//  └─ Build()*
//       └─ returns UI
// ------------------------------------------
// StatefulWidget (Widget + State)
// Widget (Configuration):
//  ├─ Immutable inputs
//  └─ CreateState()* - Creates and returns the State object
// +
// State:
//  ├─ Mutable variables
//  ├─ SetState() - Triggers UI rebuild
//  └─ Build()* - Returns UI based on current state
// ------------------------------------------
// Stateless Widget:
// A single class that describes UI based only on input parameters.
// Doesn't change and is constant
// Overrides build method and answers the question 
// "What should this widget look like?"

// Stateful Widget:
// It has 2 parts: Widget & State Class
// Widget: 
// Handles immutable input (Config, Static Properties etc.)
// Overrides createstate method which creates and returns the State object
// State Class: 
// Manages the mutable behavior and changing data, using the widget’s configuration as a reference.
// It rebuilds UI, reacts to Users actions, API etc.
// Overrides build method and answers the question 
// "What should this widget look like, what it should do, how it should behave, what can user do etc.?"
// ------------------------------------------