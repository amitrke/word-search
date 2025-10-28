import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/puzzle.dart';
import '../models/user_profile.dart';
import '../providers/auth_provider.dart';
import '../providers/user_progress_provider.dart';
import '../widgets/word_line_painter.dart';
import '../widgets/selection_line_painter.dart';

class PuzzleScreen extends StatefulWidget {
  final Puzzle puzzle;
  final int levelNumber;

  const PuzzleScreen({
    super.key,
    required this.puzzle,
    required this.levelNumber,
  });

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  final Set<String> foundWords = {};
  final Map<String, List<Map<String, int>>> foundWordPaths = {}; // Store paths for drawing lines
  final Set<String> selectedCells = {};
  final List<Map<String, int>> selectedPath = [];
  bool isDragging = false;
  Map<String, int>? _dragStartCell; // Store the starting cell of drag

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progressProvider =
        Provider.of<UserProgressProvider>(context, listen: false);
    final progress = await progressProvider.loadPuzzleProgress(widget.puzzle.id);

    if (progress != null && mounted) {
      setState(() {
        foundWords.addAll(progress.foundWords);
        // Reconstruct paths for found words
        for (final word in progress.foundWords) {
          _reconstructWordPath(word);
        }
      });
    }
  }

  void _reconstructWordPath(String word) {
    // Find the word in puzzle words
    final puzzleWord = widget.puzzle.words.firstWhere(
      (w) => w.word.toUpperCase() == word.toUpperCase(),
      orElse: () => widget.puzzle.words.first,
    );

    // Build the path based on start position and direction
    final path = <Map<String, int>>[];
    int row = puzzleWord.startRow;
    int col = puzzleWord.startCol;

    for (int i = 0; i < puzzleWord.word.length; i++) {
      path.add({'row': row, 'col': col});

      // Move to next position based on direction
      switch (puzzleWord.direction) {
        case 'horizontal':
          col++;
          break;
        case 'vertical':
          row++;
          break;
        case 'diagonal-down':
          row++;
          col++;
          break;
        case 'diagonal-up':
          row++;
          col--;
          break;
      }
    }

    foundWordPaths[word] = path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Level ${widget.levelNumber} - ${widget.puzzle.theme}'),
            Text(
              '${widget.puzzle.gridSize}×${widget.puzzle.gridSize} • ${foundWords.length}/${widget.puzzle.words.length} words',
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
        final row = (details.localPosition.dy / cellSize).floor();
        final col = (details.localPosition.dx / cellSize).floor();

        if (row >= 0 && row < widget.puzzle.gridSize &&
            col >= 0 && col < widget.puzzle.gridSize) {
          setState(() {
            isDragging = true;
            _dragStartCell = {'row': row, 'col': col};
            selectedCells.clear();
            selectedPath.clear();

            // Add start cell
            selectedCells.add('$row,$col');
            selectedPath.add({'row': row, 'col': col});
          });
        }
      },
      onPanUpdate: (details) {
        if (isDragging && _dragStartCell != null) {
          setState(() {
            _updateSelectionAlongLine(details.localPosition, cellSize);
          });
        }
      },
      onPanEnd: (details) {
        setState(() {
          isDragging = false;
          _dragStartCell = null;
        });
        _checkSelectedWord();
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!, width: 2),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                // Grid
                GridView.builder(
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
                // Line overlay for found words
                Positioned.fill(
                  child: CustomPaint(
                    painter: WordLinePainter(
                      foundWordPaths: foundWordPaths,
                      cellSize: cellSize,
                      gridSize: widget.puzzle.gridSize,
                    ),
                  ),
                ),
                // Selection line overlay
                if (isDragging && selectedPath.isNotEmpty)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: SelectionLinePainter(
                        selectedPath: selectedPath,
                        cellSize: cellSize,
                      ),
                    ),
                  ),
              ],
            ),
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

  void _updateSelectionAlongLine(Offset currentPosition, double cellSize) {
    if (_dragStartCell == null) return;

    // Get current cell
    final currentRow = (currentPosition.dy / cellSize).floor();
    final currentCol = (currentPosition.dx / cellSize).floor();

    // Clear previous selection
    selectedCells.clear();
    selectedPath.clear();

    // Get all cells along the line using Bresenham's algorithm
    final cells = _getCellsAlongLine(
      _dragStartCell!['row']!,
      _dragStartCell!['col']!,
      currentRow,
      currentCol,
    );

    // Add all cells to selection
    for (final cell in cells) {
      final row = cell['row']!;
      final col = cell['col']!;

      // Check bounds
      if (row >= 0 && row < widget.puzzle.gridSize &&
          col >= 0 && col < widget.puzzle.gridSize) {
        selectedCells.add('$row,$col');
        selectedPath.add(cell);
      }
    }
  }

  // Bresenham's line algorithm to get all cells along a line
  List<Map<String, int>> _getCellsAlongLine(
      int x0, int y0, int x1, int y1) {
    final cells = <Map<String, int>>[];

    int dx = (x1 - x0).abs();
    int dy = (y1 - y0).abs();
    int sx = x0 < x1 ? 1 : -1;
    int sy = y0 < y1 ? 1 : -1;
    int err = dx - dy;

    int x = x0;
    int y = y0;

    while (true) {
      cells.add({'row': x, 'col': y});

      if (x == x1 && y == y1) break;

      int e2 = 2 * err;
      if (e2 > -dy) {
        err -= dy;
        x += sx;
      }
      if (e2 < dx) {
        err += dx;
        y += sy;
      }
    }

    return cells;
  }

  void _checkSelectedWord() async {
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
            // Store the path for drawing the line
            foundWordPaths[puzzleWord.word] = List.from(selectedPath);
          });

          // Save progress
          _saveProgress();

          // Show success feedback
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Found: ${puzzleWord.word}!'),
                duration: const Duration(seconds: 1),
                backgroundColor: Colors.green,
              ),
            );
          }

          // Check if puzzle is complete
          if (foundWords.length == widget.puzzle.words.length) {
            _handlePuzzleCompletion();
          }

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

  Future<void> _saveProgress() async {
    final progressProvider =
        Provider.of<UserProgressProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final userId = authProvider.currentProfile?.userId ?? 'guest';
    final progress = UserPuzzleProgress(
      puzzleId: widget.puzzle.id,
      userId: userId,
      foundWords: foundWords.toList(),
      completed: foundWords.length == widget.puzzle.words.length,
      completedAt: foundWords.length == widget.puzzle.words.length
          ? DateTime.now()
          : null,
    );

    await progressProvider.savePuzzleProgress(progress);
  }

  Future<void> _handlePuzzleCompletion() async {
    final progressProvider =
        Provider.of<UserProgressProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Mark level as completed
    final newLevelUnlocked =
        await progressProvider.completeLevel(widget.levelNumber);

    if (!mounted) return;

    // Show completion dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.amber, size: 32),
            SizedBox(width: 8),
            Text('Level Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You completed Level ${widget.levelNumber}!',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Found all ${widget.puzzle.words.length} words!',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            if (newLevelUnlocked && widget.levelNumber < 30)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_open, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Level ${widget.levelNumber + 1} unlocked!',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (widget.levelNumber == 30)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.emoji_events, color: Colors.purple, size: 32),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ALL LEVELS COMPLETED! YOU ARE A LEGEND! 🏆',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (newLevelUnlocked) const SizedBox(height: 16),
            if (authProvider.isGuest) ...[
              const Text(
                'Sign in to save your progress across devices!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (authProvider.isGuest)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Go back to home
              },
              child: const Text('Sign In'),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to home
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
