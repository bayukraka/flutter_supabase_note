import 'package:flutter/material.dart';
// supabase package for flutter
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // init supabase on the project
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    // got it from supabase project->setting
    url: 'https://ghomubtasbkcyfubxqsm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdob211YnRhc2JrY3lmdWJ4cXNtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjQyNzUwMjksImV4cCI6MjAzOTg1MTAyOX0.ezvkSL0YmAxWH1XKejbnmdRYL8QukaAQ-jBS7EozEi4',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Supabase Notes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const MyHomePage(title: 'Notes'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // steam or realtime data from supabase table
  final _notesStream =
      Supabase.instance.client.from('notes').stream(primaryKey: ['id']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      // stream builder for show the data
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _notesStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              // the hatefull loading
              child: CircularProgressIndicator(),
            );
          }
          final notes = snapshot.data!;

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(notes[index]['body']),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: ((context) {
              return SimpleDialog(
                title: const Text('Add a Note'),
                contentPadding: const EdgeInsets.symmetric(horizontal: 25),
                children: [
                  // adding data to supabase
                  TextFormField(
                    onFieldSubmitted: (value) async {
                      await Supabase.instance.client
                          .from('notes')
                          .insert({'body': value});
                    },
                  ),
                ],
              );
            }),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
