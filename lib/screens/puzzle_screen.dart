import 'package:flutter/material.dart';
import '../models/puzzle.dart';

class PuzzleScreen extends StatefulWidget {
  final Puzzle puzzle;

  const PuzzleScreen({super.key, required this.puzzle});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  final Set<String> foundWords = {};
  final Set<String> selectedCells = {};
  final List<Map<String, int>> selectedPath = [];
  bool isDragging = false;
  Map<String, int>? selectionDirection;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.puzzle.theme),
            Text(
              '${widget.puzzle.difficulty.toUpperCase()} • ${foundWords.length}/${widget.puzzle.words.length} words',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Puzzle Grid
            _buildGrid(),
            const SizedBox(height: 24),

            // Progress indicator
            _buildProgress(),
            const SizedBox(height: 16),

            // Word List
            _buildWordList(),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    final grid2D = widget.puzzle.grid2D;
    final screenWidth = MediaQuery.of(context).size.width;
    final gridWidth = screenWidth - 32; // Account for padding
    final cellSize = gridWidth / widget.puzzle.gridSize;

    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          isDragging = true;
          selectedCells.clear();
          selectedPath.clear();
          selectionDirection = null;
        });
        _handleCellSelection(details.localPosition, cellSize);
      },
      onPanUpdate: (details) {
        if (isDragging) {
          _handleCellSelection(details.localPosition, cellSize);
        }
      },
      onPanEnd: (details) {
        setState(() {
          isDragging = false;
        });
        _checkSelectedWord();
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!, width: 2),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: AspectRatio(
          aspectRatio: 1,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.puzzle.gridSize,
            ),
            itemCount: widget.puzzle.gridSize * widget.puzzle.gridSize,
            itemBuilder: (context, index) {
              final row = index ~/ widget.puzzle.gridSize;
              final col = index % widget.puzzle.gridSize;
              final letter = grid2D[row][col];
              final cellKey = '$row,$col';
              final isSelected = selectedCells.contains(cellKey);

              return Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey[200]!,
                    width: 0.5,
                  ),
                  color: isSelected ? Colors.blue[100] : Colors.white,
                ),
                child: Center(
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontSize: cellSize * 0.5,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.blue[900] : Colors.black87,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProgress() {
    final progress = foundWords.length / widget.puzzle.words.length;
    final percentage = (progress * 100).toInt();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildWordList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Words to Find',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.puzzle.words.map((word) {
            final isFound = foundWords.contains(word.word);
            return InkWell(
              onTap: () {
                _showWordHint(word);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isFound
                      ? Colors.green[100]
                      : Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isFound ? Colors.green : Colors.grey[300]!,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isFound)
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green,
                      ),
                    if (isFound) const SizedBox(width: 4),
                    Text(
                      word.word,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration:
                            isFound ? TextDecoration.lineThrough : null,
                        color: isFound ? Colors.green[800] : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        if (foundWords.length == widget.puzzle.words.length)
          _buildCompletionMessage(),
      ],
    );
  }

  Widget _buildCompletionMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green, width: 2),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.celebration,
            size: 48,
            color: Colors.green,
          ),
          const SizedBox(height: 8),
          const Text(
            '🎉 Congratulations! 🎉',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'You found all ${widget.puzzle.words.length} words!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.green[800],
            ),
          ),
        ],
      ),
    );
  }

  void _showWordHint(PuzzleWord word) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(word.word),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hint:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(word.hint),
            const SizedBox(height: 16),
            Text(
              'Direction: ${word.direction}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleCellSelection(Offset position, double cellSize) {
    final row = (position.dy / cellSize).floor();
    final col = (position.dx / cellSize).floor();

    // Check if the position is within bounds
    if (row < 0 || row >= widget.puzzle.gridSize || 
        col < 0 || col >= widget.puzzle.gridSize) {
      return;
    }

    final cellKey = '$row,$col';
    
    // If this is a new cell
    if (!selectedCells.contains(cellKey)) {
      if (selectedPath.isEmpty) {
        // First cell - just add it
        setState(() {
          selectedCells.add(cellKey);
          selectedPath.add({'row': row, 'col': col});
        });
      } else if (selectedPath.length == 1) {
        // Second cell - establish direction
        final lastCell = selectedPath.last;
        if (_isAdjacent(lastCell, {'row': row, 'col': col})) {
          setState(() {
            selectionDirection = {
              'rowDelta': row - lastCell['row']!,
              'colDelta': col - lastCell['col']!,
            };
            selectedCells.add(cellKey);
            selectedPath.add({'row': row, 'col': col});
          });
        }
      } else {
        // Subsequent cells - must follow the same direction
        final lastCell = selectedPath.last;
        final expectedRow = lastCell['row']! + selectionDirection!['rowDelta']!;
        final expectedCol = lastCell['col']! + selectionDirection!['colDelta']!;
        
        if (row == expectedRow && col == expectedCol) {
          setState(() {
            selectedCells.add(cellKey);
            selectedPath.add({'row': row, 'col': col});
          });
        }
      }
    }
  }

  bool _isAdjacent(Map<String, int> cell1, Map<String, int> cell2) {
    final rowDiff = (cell1['row']! - cell2['row']!).abs();
    final colDiff = (cell1['col']! - cell2['col']!).abs();
    
    // Adjacent includes horizontal, vertical, and diagonal (max diff of 1 in each direction)
    return rowDiff <= 1 && colDiff <= 1 && (rowDiff + colDiff) > 0;
  }

  void _checkSelectedWord() {
    if (selectedPath.isEmpty) {
      return;
    }

    // Build the selected word from the path
    final grid2D = widget.puzzle.grid2D;
    final selectedWord = selectedPath
        .map((cell) => grid2D[cell['row']!][cell['col']!])
        .join('');

    // Check if the selected word matches any puzzle word (forward or backward)
    for (final puzzleWord in widget.puzzle.words) {
      if (!foundWords.contains(puzzleWord.word)) {
        if (selectedWord.toUpperCase() == puzzleWord.word.toUpperCase() ||
            selectedWord.split('').reversed.join().toUpperCase() == puzzleWord.word.toUpperCase()) {
          setState(() {
            foundWords.add(puzzleWord.word);
          });
          
          // Show success feedback
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Found: ${puzzleWord.word}!'),
              duration: const Duration(seconds: 1),
              backgroundColor: Colors.green,
            ),
          );
          break;
        }
      }
    }

    // Clear selection
    setState(() {
      selectedCells.clear();
      selectedPath.clear();
    });
  }
}
