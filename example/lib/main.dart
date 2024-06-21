import 'package:example/example.schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ajv/ajv_validator.dart';
import 'package:json_view/json_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ajvValidator = AJVValidator();
  var errorMap = {};
  Future<dynamic>? ajvFuture;

  @override
  void initState() {
    super.initState();
    ajvFuture = ajvValidator.setup();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ajvFuture,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text('AJV Example'),
          ),
          body: Builder(
            builder: (context) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Text('Initialing...'));
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    const Text('SCHEMA'),
                    const JsonView(
                      json: exampleFormSchema,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                    ),
                    const Divider(),
                    const Text('DATA'),
                    const JsonView(
                      json: exampleFormData,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                    ),
                    Builder(builder: (context) {
                      if (errorMap.isNotEmpty) {
                        return Column(
                          children: [
                            const Divider(),
                            const Text('VALIDATION RESULT'),
                            JsonView(
                              json: errorMap,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                            ),
                          ],
                        );
                      }

                      return const Text('Click "Validate" to get result!');
                    }),
                  ],
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              try {
                ajvValidator.registerSchema(exampleFormSchema);

                final result = ajvValidator.validate(exampleFormData);
                final transformedError = result.keys.fold(
                  {},
                  (r, k) => {
                    ...r,
                    k: result[k]!.fold(
                      {},
                      (r1, e1) => {...r1, e1.keyword: e1.message},
                    )
                  },
                );

                setState(() {
                  errorMap = transformedError;
                });
              } catch (e) {
                print(e);
              }
            },
            tooltip: 'Validate',
            label: const Text('Validate'),
          ), // This trailing comma makes auto-formatting nicer for build methods.
        );
      },
    );
  }
}
