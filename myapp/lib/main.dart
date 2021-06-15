import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';

void main() => runApp(MyApp());

typedef Callback = void Function();

class Config {
  static const tabTitle = 'GM lang';
  static const icon = '◉';
  static const barTitle = icon + ' GM';
  static const rawWebsite = 'https://raw.gm-lang.org/';

  static RegExp nameFormat = RegExp(
    r"gm(\.[\w-]+)*",
    caseSensitive: true,
    multiLine: false,
    unicode: true,
  );

  // file system
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Config.tabTitle,
      theme: ThemeData(
        primarySwatch: Colors.red,
        textTheme: GoogleFonts.sourceSansProTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: MyMainBody(),
    );
  }
}

class MyMainBody extends StatefulWidget {
  MyMainBody({Key? key}) : super(key: key);

  // final String concept;

  @override
  _MyMainBodyState createState() => _MyMainBodyState();
}

class _MyMainBodyState extends State<MyMainBody> {
  final myController = TextEditingController();

  bool _typing = false;
  // String _code = "";
  Html _code_html = Html(data: "");

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
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
                  controller: myController,
                  onUpdate: _update_body,
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
        body: SingleChildScrollView(child: _code_html), // TODO
      );

  void _reverse_typing() => setState(() {
        _typing = !_typing;
      });

  void _update_body() => setState(() async {
        String name = myController.text;

        final response_code = await __fetch_code(name);

        if (response_code.statusCode == 200) {
          // If the server did return a 200 OK response,

          // _code = response_code.body;
          _reverse_typing();
        } else {
          // If the server did not return a 200 OK response,
          // then throw an exception.
          throw Exception('Failed to load ' + name);
        }
        print(name);
      });

  Future<http.Response> __fetch_code(String name) =>
      http.get(Uri.parse(Config.rawWebsite + name));

  Future<http.Response> __fetch_time(String name) =>
      http.get(Uri.parse(Config.rawWebsite + name + "/time"));
}

class InputBox extends StatelessWidget {
  InputBox({Key? key, required this.controller, required this.onUpdate})
      : super(key: key);
  final Callback onUpdate;
  final controller;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) => Form(
        key: _formKey,
        // alignment: Alignment.centerLeft,
        child: Row(
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(
                color: Colors.white,
                child: TextFormField(
                  controller: controller,
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    // border: InputBorder.none,
                    labelText: 'Full Name of Concept',
                    // helperText: 'gm(.[\w-])*',
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    } else if (Config.nameFormat
                            .stringMatch(value)
                            .toString()
                            .length !=
                        value.length) {
                      return 'Format error';
                    }
                    return null;
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Validate will return true if the form is valid, or false if
                  // the form is invalid.
                  if (_formKey.currentState!.validate()) {
                    onUpdate();
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //     SnackBar(content: Text('Processing Data')));
                  }
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      );
}
