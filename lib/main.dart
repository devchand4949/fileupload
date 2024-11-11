import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List record = [];

  Future<void> datafromdb() async {
    try {
      // Use 10.0.2.2 for localhost on Android emulator
      String uri = "http://10.0.2.2/23msit049/fileuploder/fileview.php";
      var response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        setState(() {
          record = jsonDecode(response.body);
        });
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  @override
  void initState() {
    datafromdb();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Image Grid"),
        ),
        body: record.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: record.length,
          itemBuilder: (context, index) {
            // Ensure proper URL encoding for spaces in the URL
            String imageUrl = "http://10.0.2.2/23msit049/fileuploder/images/" + record[index]["file_image"];
            String audioUrl = "http://10.0.2.2/23msit049/fileuploder/audio/" + record[index]['file_audio'];

            return Container(
              child: Column(
                children: [
                  Image.network(
                    imageUrl,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error);
                    },
                    height: 100,
                    width: 100,
                  ),
                  const SizedBox(height: 10),
                  Text(record[index]["file_name"]),
                  TextButton(
                    onPressed: () async {
                      try {
                        final player = AudioPlayer();
                        // Play audio with proper timeout handling
                        await player.play(UrlSource(audioUrl));
                      } catch (e) {
                        print('Error playing audio: $e');
                      }
                    },
                    child: const Text("Play"),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
