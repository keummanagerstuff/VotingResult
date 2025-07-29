import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
    return Scaffold(
        backgroundColor: Colors.white,
        body: StreamBuilder<Map<String, int>>(
          stream: getVoteCounts(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return const Center(child: CircularProgressIndicator());
            final data = snapshot.data!;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                resultTile("👍 Like", data['like']!),
                resultTile("👎 Dislike", data['dislike']!),
                resultTile("🤔 Hold", data['hold']!),
                const SizedBox(height: 20),
                Text("총 투표자 수: ${data.values.reduce((a, b) => a + b)}",
                    style: const TextStyle(fontSize: 18)),
              ],
            );
          },
        ));
  }

  Widget resultTile(String label, int count) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontSize: 22)),
        trailing: Text('$count명', style: const TextStyle(fontSize: 22)),
      ),
    );
  }
}
