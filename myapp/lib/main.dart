import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

typedef Callback = void Function(String);

class Config {
  static const tabTitle = 'GM lang';
  static const icon = '◉';
  static const barTitle = icon + ' GM';
  static const htmlWebsite = 'https://raw.gm-lang.org/';

  static RegExp nameFormat = RegExp(
    r"gm(\.[\w-]+)*",
    caseSensitive: true,
    multiLine: false,
    unicode: true,
  );
}

class RouteArguments {
  final String name;
  RouteArguments(this.name);
}

class _MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        ExtractArgumentsScreen.routeName: (context) => ExtractArgumentsScreen(),
      },
      // Provide a function to handle named routes.
      // Use this function to identify the named
      // route being pushed, and create the correct
      // Screen.
      onGenerateRoute: (settings) {
        // If you push the PassArguments route
        if (settings.name == PassArgumentsScreen.routeName) {
          // Cast the arguments to the correct
          // type: ScreenArguments.
          final args = settings.arguments as ScreenArguments;

          // Then, extract the required data from
          // the arguments and pass the data to the
          // correct screen.
          return MaterialPageRoute(
            builder: (context) {
              return PassArgumentsScreen(
                title: args.title,
                message: args.message,
              );
            },
          );
        }
        // The code only supports
        // PassArgumentsScreen.routeName right now.
        // Other values need to be implemented if we
        // add them. The assertion here will help remind
        // us of that higher up in the call stack, since
        // this assertion would otherwise fire somewhere
        // in the framework.
        assert(false, 'Need to implement ${settings.name}');
        return null;
      },
      title: 'Navigation with Arguments',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // A button that navigates to a named route.
            // The named route extracts the arguments
            // by itself.
            ElevatedButton(
              onPressed: () {
                // When the user taps the button,
                // navigate to a named route and
                // provide the arguments as an optional
                // parameter.
                Navigator.pushNamed(
                  context,
                  ExtractArgumentsScreen.routeName,
                  arguments: ScreenArguments(
                    'Extract Arguments Screen',
                    'This message is extracted in the build method.',
                  ),
                );
              },
              child: Text('Navigate to screen that extracts arguments'),
            ),
            // A button that navigates to a named route.
            // For this route, extract the arguments in
            // the onGenerateRoute function and pass them
            // to the screen.
            ElevatedButton(
              onPressed: () {
                // When the user taps the button, navigate
                // to a named route and provide the arguments
                // as an optional parameter.
                Navigator.pushNamed(
                  context,
                  PassArgumentsScreen.routeName,
                  arguments: ScreenArguments(
                    'Accept Arguments Screen',
                    'This message is extracted in the onGenerateRoute function.',
                  ),
                );
              },
              child: Text('Navigate to a named that accepts arguments'),
            ),
          ],
        ),
      ),
    );
  }
}

// A Widget that extracts the necessary arguments from
// the ModalRoute.
class ExtractArgumentsScreen extends StatelessWidget {
  static const routeName = '/extractArguments';

  @override
  Widget build(BuildContext context) {
    // Extract the arguments from the current ModalRoute
    // settings and cast them as ScreenArguments.
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(args.title),
      ),
      body: Center(
        child: Text(args.message),
      ),
    );
  }
}

// A Widget that accepts the necessary arguments via the
// constructor.
class PassArgumentsScreen extends StatelessWidget {
  static const routeName = '/passArguments';

  final String title;
  final String message;

  // This Widget accepts the arguments as constructor
  // parameters. It does not extract the arguments from
  // the ModalRoute.
  //
  // The arguments are extracted by the onGenerateRoute
  // function provided to the MaterialApp widget.
  const PassArgumentsScreen({
    Key? key,
    required this.title,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(message),
      ),
    );
  }
}

// You can pass any object to the arguments parameter.
// In this example, create a class that contains both
// a customizable title and message.
class ScreenArguments {
  final String title;
  final String message;

  ScreenArguments(this.title, this.message);
}

//
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  static const srcRoute = '/';

  @override
  Widget build(BuildContext context) {
    // final args = ModalRoute.of(context)!.settings.arguments as RouteArguments;

    return MaterialApp(
      title: Config.tabTitle,
      theme: ThemeData(
        primarySwatch: Colors.red,
        textTheme: GoogleFonts.sourceSansProTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      initialRoute: '/',
      routes: {
        "/": (context) => MyMainBody(name: ""),
      },
      onGenerateRoute: (settings) {
        if (settings.name != srcRoute) {
          print(settings.name!);

          return MaterialPageRoute(
            builder: (context) {
              //in your example: settings.name = "/gm"
              final name = settings.name!.substring(1);
              return MyMainBody(name: name);
            },
          );
        }
        // The code only supports
        // PassArgumentsScreen.routeName right now.
        // Other values need to be implemented if we
        // add them. The assertion here will help remind
        // us of that higher up in the call stack, since
        // this assertion would otherwise fire somewhere
        // in the framework.
        // assert(false, 'Need to implement ${settings.name}');
        return null;
      },
    );
  }
}

class MyMainBody extends StatefulWidget {
  const MyMainBody({Key? key, required String this.name}) : super(key: key);

  final String name;

  @override
  _MyMainBodyState createState() => _MyMainBodyState();
}

class _MyMainBodyState extends State<MyMainBody> {
  bool _typing = false;
  String _code = "";

  @override
  void initState() {
    super.initState();
    if (widget.name.isNotEmpty) {
      _update_body(widget.name);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.menu),
            tooltip: 'Navigation menu',
            onPressed: null, // TODO
          ),
          title: _typing
              ? InputBox(
                  onUpdate: (name) {
                    _update_body(name);
                  },
                )
              : Text(Config.barTitle),
          actions: <Widget>[
            IconButton(
              icon: Icon(_typing ? Icons.close : Icons.search),
              tooltip: 'Search',
              onPressed: _reverse_typing,
            ),
          ],
          textTheme: Theme.of(context).textTheme,
          primary: false,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: SelectableText(
              _code, //TODO
              style: GoogleFonts.sourceCodePro(),
            ),
            scrollDirection: Axis.vertical,
          ),
        ),
      );

  void _update_body(String name) async {
    final response = await __fetch_code(name);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      _code = response.body;
      _close_typing();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load ' + name);
    }
    print(name);
  }

  void _close_typing() => setState(() {
        _typing = false;
      });
  void _reverse_typing() => setState(() {
        _typing = !_typing;
      });

  Future<http.Response> __fetch_code(String name) =>
      http.get(Uri.parse(Config.htmlWebsite + name));
}

class InputBox extends StatelessWidget {
  InputBox({Key? key, required this.onUpdate}) : super(key: key);
  final Callback onUpdate;
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) => Form(
        key: _formKey,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                color: Colors.white,
                child: TextFormField(
                  controller: _controller,
                  autofocus: true,
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    // border: InputBorder.none,
                    labelText: 'Full Name of Concept',
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    } else if (Config.nameFormat
                            .stringMatch(value)
                            .toString()
                            .length !=
                        value.length) {
                      // TODO
                      return 'Format error';
                    }
                    return null;
                  },
                  onFieldSubmitted: (text) {
                    if (_formKey.currentState!.validate()) {
                      onUpdate(text);
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // TODO
                    onUpdate(_controller.text);
                  }
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      );
}
