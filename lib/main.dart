import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voting_result/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.web,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  Stream<Map<String, int>> getVoteCounts() {
    return FirebaseFirestore.instance
        .collection('votes')
        .snapshots()
        .map((snapshot) {
      final counts = {
        'like': 0,
        'dislike': 0,
        'hold': 0,
      };

      for (final doc in snapshot.docs) {
        final vote = doc.data()['vote'];
        if (counts.containsKey(vote)) {
          counts[vote] = counts[vote]! + 1;
        }
      }

      return counts;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = screenHeight * 0.6;

    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<Map<String, int>>(
        stream: getVoteCounts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(60),
            child: Column(
              children: [
                Text("Total: ${data.values.reduce((a, b) => a + b)}",
                    style: GoogleFonts.notoSans(
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    )),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                          child: resultTile("assets/images/1f44d.png Yes!",
                              data['like']!, cardHeight)),
                      const SizedBox(
                        width: 36,
                      ),
                      Expanded(
                          child: resultTile("assets/images/1f914.png Hmmm..",
                              data['hold']!, cardHeight)),
                      const SizedBox(
                        width: 36,
                      ),
                      Expanded(
                          child: resultTile("assets/images/1f44e.png Nope",
                              data['dislike']!, cardHeight)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget resultTile(String label, int count, double cardHeight) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[300]!, width: 2),
      ),
      child: Container(
        height: cardHeight,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(label.split(" ").first),
            const SizedBox(height: 12),
            Text(
              '$count',
              style: GoogleFonts.notoSans(
                fontSize: 48,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label.split(" ").last,
              style: GoogleFonts.notoSans(
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
