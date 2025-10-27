import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/puzzle.dart';
import 'puzzle_screen.dart';

class PuzzleListScreen extends StatefulWidget {
  const PuzzleListScreen({super.key});

  @override
  State<PuzzleListScreen> createState() => _PuzzleListScreenState();
}

class _PuzzleListScreenState extends State<PuzzleListScreen> {
  String selectedDifficulty = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Search Puzzles'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Difficulty Filter
          _buildDifficultyFilter(),

          // Puzzle List
          Expanded(
            child: _buildPuzzleList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All'),
            const SizedBox(width: 8),
            _buildFilterChip('simple'),
            const SizedBox(width: 8),
            _buildFilterChip('medium'),
            const SizedBox(width: 8),
            _buildFilterChip('hard'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String difficulty) {
    final isSelected = selectedDifficulty == difficulty;

    return FilterChip(
      label: Text(
        difficulty == 'All' ? 'All' : difficulty.toUpperCase(),
        style: TextStyle(
          color: isSelected ? Colors.white : null,
          fontWeight: isSelected ? FontWeight.bold : null,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          selectedDifficulty = difficulty;
        });
      },
      selectedColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildPuzzleList() {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('puzzles');

    // Apply difficulty filter
    if (selectedDifficulty != 'All') {
      query = query.where('difficulty', isEqualTo: selectedDifficulty);
    }

    // Limit results
    query = query.limit(50);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading puzzles...'),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No puzzles found',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try selecting a different difficulty',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        final puzzles = snapshot.data!.docs.map((doc) {
          return Puzzle.fromFirestore(
              doc.id, doc.data() as Map<String, dynamic>);
        }).toList();

        return ListView.builder(
          itemCount: puzzles.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final puzzle = puzzles[index];
            return _buildPuzzleCard(puzzle);
          },
        );
      },
    );
  }

  Widget _buildPuzzleCard(Puzzle puzzle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PuzzleScreen(puzzle: puzzle),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Difficulty emoji
              Text(
                puzzle.difficultyEmoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 16),

              // Puzzle info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      puzzle.theme,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${puzzle.difficulty.toUpperCase()} • ${puzzle.gridSize}x${puzzle.gridSize} • ${puzzle.words.length} words',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow icon
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
