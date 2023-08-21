import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  final controller = ScrollController();
  // List<String> items = List.generate(15, (index) => "Item ${index + 1}");
  List<String> items = [];
  int page = 1;
  bool hasMore = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getAllData();
    controller.addListener(() {
      if (controller.position.maxScrollExtent == controller.offset) {
        // fetch();
        getAllData();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> fetch() async {
    setState(() {
      items.addAll([
        "Item a",
        "Item b",
        "Item c",
        "Item d",
      ]);
    });
  }

  Future<void> getAllData() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    const limit = 25;
    final url = Uri.parse(
        'https://jsonplaceholder.typicode.com/posts?_limit=$limit&_page=$page');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List newItems = json.decode(response.body);

      setState(() {
        page++;

        isLoading = false;

        if (newItems.length < limit) {
          hasMore = false;
        }
        items.addAll(
          newItems.map<String>((e) {
            final number = e['id'];

            return 'Item $number';
          }).toList(),
        );
      });
    }
  }

  Future<void> refresh() async {
    setState(() {
      isLoading = false;
      hasMore = true;
      page = 1;
      items.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: ListView.builder(
          controller: controller,
          padding: const EdgeInsets.all(8),
          itemCount: items.length + 1,
          itemBuilder: (context, index) {
            if (index < items.length) {
              final item = items[index];
              return ListTile(
                title: Text(item),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                ),
                child: Center(
                  child: (hasMore)
                      ? const CircularProgressIndicator()
                      : const Text("No More data to load"),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
