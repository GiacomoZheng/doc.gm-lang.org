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

  @override
  _MyMainBodyState createState() => _MyMainBodyState();
}

class _MyMainBodyState extends State<MyMainBody> {
  bool _typing = false;
  String _code = "a\tb";

  // @override
  // void initState() {
  //   super.initState();
  // }

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

  void _reverse_typing() => setState(() {
        _typing = !_typing;
      });

  void _update_body(String name) => setState(() async {
        final response = await __fetch_code(name);

        if (response.statusCode == 200) {
          // If the server did return a 200 OK response,
          _code = response.body;
          _reverse_typing();
        } else {
          // If the server did not return a 200 OK response,
          // then throw an exception.
          throw Exception('Failed to load ' + name);
        }
        print(name);
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
