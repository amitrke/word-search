const admin = require('firebase-admin');
const OpenAI = require('openai');
const fs = require('fs');

// ============================================
// CONFIGURATION
// ============================================

const THEMES = [
  'Animals', 'Countries', 'Technology', 'Food', 'Sports',
  'Music', 'Nature', 'Movies', 'Science', 'History'
];

const DIFFICULTIES = ['simple', 'medium', 'hard'];

const GRID_SIZES = {
  simple: 8,
  medium: 12,
  hard: 15
};

const WORD_COUNTS = {
  simple: { min: 5, max: 8 },
  medium: { min: 10, max: 15 },
  hard: { min: 15, max: 20 }
};

const DIRECTIONS = [
  { dr: 0, dc: 1, name: 'horizontal' },      // →
  { dr: 1, dc: 0, name: 'vertical' },        // ↓
  { dr: 1, dc: 1, name: 'diagonal-down' },   // ↘
  { dr: 1, dc: -1, name: 'diagonal-up' }     // ↙
];

// ============================================
// FIREBASE INITIALIZATION
// ============================================

function initFirebase() {
  try {
    const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);

    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });

    console.log('✓ Firebase Admin initialized');
    return admin.firestore();
  } catch (error) {
    console.error('✗ Error initializing Firebase:', error.message);
    throw error;
  }
}

// ============================================
// OPENAI INITIALIZATION
// ============================================

function initOpenAI() {
  try {
    const openai = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY
    });

    console.log('✓ OpenAI initialized');
    return openai;
  } catch (error) {
    console.error('✗ Error initializing OpenAI:', error.message);
    throw error;
  }
}

// ============================================
// INVENTORY MANAGEMENT
// ============================================

async function checkInventory(db) {
  console.log('📊 Checking puzzle inventory...\n');

  try {
    // Get total puzzles count
    const totalPuzzlesSnapshot = await db.collection('puzzles').count().get();
    const totalPuzzles = totalPuzzlesSnapshot.data().count;

    // Get puzzles by difficulty
    const puzzlesByDifficulty = {};
    for (const difficulty of DIFFICULTIES) {
      const snapshot = await db
        .collection('puzzles')
        .where('difficulty', '==', difficulty)
        .count()
        .get();
      puzzlesByDifficulty[difficulty] = snapshot.data().count;
    }

    // Get puzzles by theme
    const puzzlesByTheme = {};
    for (const theme of THEMES) {
      const snapshot = await db
        .collection('puzzles')
        .where('theme', '==', theme)
        .count()
        .get();
      puzzlesByTheme[theme] = snapshot.data().count;
    }

    // Calculate usage statistics
    const totalUserPuzzlesSnapshot = await db.collection('userPuzzles').count().get();
    const totalPlayed = totalUserPuzzlesSnapshot.data().count;

    const completedSnapshot = await db
      .collection('userPuzzles')
      .where('status', '==', 'completed')
      .count()
      .get();
    const totalCompleted = completedSnapshot.data().count;

    // Calculate consumption rate (puzzles played / total puzzles)
    const consumptionRate = totalPuzzles > 0 ? (totalPlayed / totalPuzzles) * 100 : 0;

    console.log('  Inventory Status:');
    console.log(`    Total puzzles: ${totalPuzzles}`);
    console.log(`    By difficulty: Simple: ${puzzlesByDifficulty.simple || 0}, Medium: ${puzzlesByDifficulty.medium || 0}, Hard: ${puzzlesByDifficulty.hard || 0}`);
    console.log(`\n  Usage Statistics:`);
    console.log(`    Total plays: ${totalPlayed}`);
    console.log(`    Completed: ${totalCompleted}`);
    console.log(`    Consumption rate: ${consumptionRate.toFixed(1)}%\n`);

    // Log theme distribution
    console.log('  Puzzles by theme:');
    for (const theme of THEMES) {
      console.log(`    ${theme}: ${puzzlesByTheme[theme] || 0}`);
    }
    console.log('');

    return {
      totalPuzzles,
      puzzlesByDifficulty,
      puzzlesByTheme,
      totalPlayed,
      totalCompleted,
      consumptionRate
    };

  } catch (error) {
    console.error('  ⚠ Error checking inventory:', error.message);
    // Return default values to allow generation to proceed
    return {
      totalPuzzles: 0,
      puzzlesByDifficulty: {},
      puzzlesByTheme: {},
      totalPlayed: 0,
      totalCompleted: 0,
      consumptionRate: 100 // Assume high consumption to trigger generation
    };
  }
}

function shouldGeneratePuzzles(inventory, config) {
  const {
    totalPuzzles,
    consumptionRate,
    puzzlesByDifficulty,
    puzzlesByTheme
  } = inventory;

  const {
    minPuzzles = 30,
    maxPuzzles = 200,
    minConsumptionRate = 20,
    minPerDifficulty = 8,
    minPerTheme = 3
  } = config;

  console.log('🤔 Evaluating generation need...\n');

  // Check 1: Have we hit the maximum?
  if (totalPuzzles >= maxPuzzles) {
    console.log(`  ❌ Inventory full (${totalPuzzles}/${maxPuzzles} puzzles)`);
    console.log(`  → Skipping generation to avoid waste\n`);
    return { shouldGenerate: false, reason: 'inventory_full' };
  }

  // Check 2: Is consumption rate too low?
  if (totalPuzzles >= minPuzzles && consumptionRate < minConsumptionRate) {
    console.log(`  ❌ Low consumption rate (${consumptionRate.toFixed(1)}% < ${minConsumptionRate}%)`);
    console.log(`  → Users haven't played enough existing puzzles yet\n`);
    return { shouldGenerate: false, reason: 'low_consumption' };
  }

  // Check 3: Do we need more puzzles overall?
  if (totalPuzzles < minPuzzles) {
    console.log(`  ✅ Inventory low (${totalPuzzles}/${minPuzzles} puzzles)`);
    console.log(`  → Generating ${minPuzzles - totalPuzzles}+ puzzles\n`);
    return {
      shouldGenerate: true,
      reason: 'low_inventory',
      targetCount: Math.max(14, minPuzzles - totalPuzzles)
    };
  }

  // Check 4: Are any difficulty levels low?
  const lowDifficulties = DIFFICULTIES.filter(
    diff => (puzzlesByDifficulty[diff] || 0) < minPerDifficulty
  );

  if (lowDifficulties.length > 0) {
    console.log(`  ⚠ Low inventory for: ${lowDifficulties.join(', ')}`);
    console.log(`  → Generating puzzles for these difficulties\n`);
    return {
      shouldGenerate: true,
      reason: 'unbalanced_difficulty',
      focusDifficulties: lowDifficulties,
      targetCount: lowDifficulties.length * (minPerDifficulty + 2)
    };
  }

  // Check 5: Are any themes low?
  const lowThemes = THEMES.filter(
    theme => (puzzlesByTheme[theme] || 0) < minPerTheme
  );

  if (lowThemes.length > 0) {
    console.log(`  ⚠ Low inventory for themes: ${lowThemes.join(', ')}`);
    console.log(`  → Generating puzzles for these themes\n`);
    return {
      shouldGenerate: true,
      reason: 'unbalanced_theme',
      focusThemes: lowThemes,
      targetCount: lowThemes.length * minPerTheme
    };
  }

  // All checks passed - we have enough puzzles
  console.log(`  ✅ Inventory healthy (${totalPuzzles} puzzles, ${consumptionRate.toFixed(1)}% consumption)`);
  console.log(`  → No generation needed\n`);
  return { shouldGenerate: false, reason: 'inventory_healthy' };
}

// ============================================
// AI WORD GENERATION
// ============================================

async function generateWordList(openai, theme, difficulty) {
  const params = WORD_COUNTS[difficulty];
  const wordCount = Math.floor(Math.random() * (params.max - params.min + 1)) + params.min;

  const difficultyGuidance = {
    simple: 'common, everyday words that are easy to recognize',
    medium: 'moderately challenging words with some variety',
    hard: 'advanced vocabulary and less common words'
  };

  const prompt = `Generate a word search puzzle with the following specifications:

Theme: ${theme}
Difficulty: ${difficulty}
Number of words: ${wordCount}

Requirements:
1. Provide exactly ${wordCount} words related to "${theme}"
2. Each word should have a brief hint (one sentence, under 100 characters)
3. Words should be:
   - Appropriate for all ages
   - Clearly related to the theme
   - Varied in length (3-12 letters)
   - Single words (no spaces or hyphens)
   - English language
   - ${difficultyGuidance[difficulty]}
4. Ensure diversity in word choices

Return ONLY valid JSON (no markdown, no explanations) in this exact format:
{
  "words": ["word1", "word2", ...],
  "hints": ["hint for word1", "hint for word2", ...]
}`;

  try {
    const response = await openai.chat.completions.create({
      model: 'gpt-3.5-turbo',
      messages: [
        {
          role: 'system',
          content: 'You are a puzzle generator. Always respond with valid JSON only, no markdown formatting.'
        },
        { role: 'user', content: prompt }
      ],
      temperature: 0.8,
      max_tokens: 1000
    });

    const content = response.choices[0].message.content.trim();

    // Remove markdown code blocks if present
    const jsonStr = content
      .replace(/```json\s*/g, '')
      .replace(/```\s*/g, '')
      .trim();

    const data = JSON.parse(jsonStr);

    // Validate response
    if (!data.words || !Array.isArray(data.words) || data.words.length === 0) {
      throw new Error('Invalid words array in response');
    }

    if (!data.hints || !Array.isArray(data.hints) || data.hints.length !== data.words.length) {
      throw new Error('Invalid hints array in response');
    }

    // Clean up words (uppercase, remove spaces)
    data.words = data.words.map(w => w.toUpperCase().replace(/\s+/g, '').replace(/[^A-Z]/g, ''));

    // Filter out empty words
    const validIndices = [];
    for (let i = 0; i < data.words.length; i++) {
      if (data.words[i].length >= 3) {
        validIndices.push(i);
      }
    }

    data.words = validIndices.map(i => data.words[i]);
    data.hints = validIndices.map(i => data.hints[i]);

    console.log(`  Generated ${data.words.length} words for ${theme} (${difficulty})`);
    return data;

  } catch (error) {
    console.error(`  ✗ Error generating word list: ${error.message}`);
    throw error;
  }
}

// ============================================
// GRID GENERATION
// ============================================

function canPlaceWord(grid, word, row, col, dir, gridSize) {
  for (let i = 0; i < word.length; i++) {
    const r = row + dir.dr * i;
    const c = col + dir.dc * i;

    if (r < 0 || r >= gridSize || c < 0 || c >= gridSize) {
      return false;
    }

    const cell = grid[r][c];
    if (cell !== '' && cell !== word[i]) {
      return false;
    }
  }
  return true;
}

function placeWord(grid, word, row, col, dir) {
  for (let i = 0; i < word.length; i++) {
    const r = row + dir.dr * i;
    const c = col + dir.dc * i;
    grid[r][c] = word[i];
  }
}

function placeWordsInGrid(words, gridSize) {
  const grid = Array(gridSize).fill(null).map(() =>
    Array(gridSize).fill('')
  );

  const placedWords = [];

  // Sort by length (longest first for better placement)
  const sortedWords = [...words].sort((a, b) => b.length - a.length);

  for (const word of sortedWords) {
    let placed = false;
    let attempts = 0;
    const maxAttempts = 200;

    while (!placed && attempts < maxAttempts) {
      const row = Math.floor(Math.random() * gridSize);
      const col = Math.floor(Math.random() * gridSize);
      const dir = DIRECTIONS[Math.floor(Math.random() * DIRECTIONS.length)];

      if (canPlaceWord(grid, word, row, col, dir, gridSize)) {
        placeWord(grid, word, row, col, dir);
        placedWords.push({
          word: word,
          startRow: row,
          startCol: col,
          direction: dir.name
        });
        placed = true;
      }

      attempts++;
    }

    if (!placed) {
      console.warn(`  ⚠ Could not place word: ${word} (tried ${maxAttempts} times)`);
    }
  }

  // Fill empty cells with random letters
  const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  for (let i = 0; i < gridSize; i++) {
    for (let j = 0; j < gridSize; j++) {
      if (grid[i][j] === '') {
        grid[i][j] = letters[Math.floor(Math.random() * letters.length)];
      }
    }
  }

  return { grid, placedWords };
}

// ============================================
// PUZZLE GENERATION
// ============================================

async function generatePuzzle(openai, theme, difficulty) {
  // Get words from ChatGPT
  const { words, hints } = await generateWordList(openai, theme, difficulty);

  // Place in grid
  const gridSize = GRID_SIZES[difficulty];
  const { grid, placedWords } = placeWordsInGrid(words, gridSize);

  // Convert 2D grid to array of strings (Firestore doesn't support nested arrays)
  const gridStrings = grid.map(row => row.join(''));

  // Create puzzle object
  const puzzle = {
    theme,
    difficulty,
    gridSize,
    grid: gridStrings,  // Array of strings instead of 2D array
    words: placedWords.map((w, i) => ({
      word: w.word,
      startRow: w.startRow,
      startCol: w.startCol,
      direction: w.direction,
      hint: hints[words.indexOf(w.word)] || `Find: ${w.word}`
    })),
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    createdBy: 'GitHub Actions',
    generatedDate: new Date().toISOString(),
    popularity: 0,
    completionCount: 0,
    averageCompletionTime: 0,
    tags: [theme.toLowerCase(), difficulty],
    version: '1.0'
  };

  return puzzle;
}

// ============================================
// MAIN FUNCTION
// ============================================

async function main() {
  console.log('🎮 Word Search Puzzle Generator');
  console.log('================================\n');

  const startTime = Date.now();
  const logEntries = [];

  try {
    // Initialize services
    const db = initFirebase();
    const openai = initOpenAI();

    // Check current inventory
    const inventory = await checkInventory(db);

    // Configuration for inventory management
    const inventoryConfig = {
      minPuzzles: parseInt(process.env.MIN_PUZZLES || '30'),
      maxPuzzles: parseInt(process.env.MAX_PUZZLES || '200'),
      minConsumptionRate: parseInt(process.env.MIN_CONSUMPTION_RATE || '20'),
      minPerDifficulty: parseInt(process.env.MIN_PER_DIFFICULTY || '8'),
      minPerTheme: parseInt(process.env.MIN_PER_THEME || '3')
    };

    // Check if force generation is enabled
    const forceGenerate = process.env.FORCE_GENERATE === 'true';

    if (forceGenerate) {
      console.log('⚡ Force generation enabled - skipping inventory checks\n');
    }

    // Decide if we should generate
    const decision = shouldGeneratePuzzles(inventory, inventoryConfig);

    if (!decision.shouldGenerate && !forceGenerate) {
      console.log('================================');
      console.log(`Reason: ${decision.reason}`);
      console.log('No puzzles generated. Exiting.');
      console.log('================================\n');

      // Save log
      fs.writeFileSync(
        'generation-log.json',
        JSON.stringify({
          skipped: true,
          reason: decision.reason,
          inventory,
          timestamp: new Date().toISOString()
        }, null, 2)
      );

      process.exit(0);
    }

    // Get configuration from environment or decision
    const puzzleCount = decision.targetCount || parseInt(process.env.PUZZLE_COUNT || '14');
    const themeFilter = process.env.THEME_FILTER || '';

    const themes = decision.focusThemes || (themeFilter ? [themeFilter] : THEMES);
    const difficulties = decision.focusDifficulties || DIFFICULTIES;

    console.log(`\nConfiguration:`);
    console.log(`  Target puzzles: ${puzzleCount}`);
    console.log(`  Themes: ${themes.join(', ')}`);
    console.log(`  Difficulties: ${difficulties.join(', ')}`);
    console.log(`  Reason: ${decision.reason}\n`);

    // Calculate puzzles per theme/difficulty
    const combinations = themes.length * difficulties.length;
    const puzzlesPerCombo = Math.ceil(puzzleCount / combinations);

    console.log(`Generating ${puzzlesPerCombo} puzzle(s) per theme/difficulty combination\n`);

    let successCount = 0;
    let errorCount = 0;

    // Generate puzzles
    for (const theme of themes) {
      for (const difficulty of difficulties) {
        for (let i = 0; i < puzzlesPerCombo; i++) {
          try {
            console.log(`[${successCount + errorCount + 1}/${puzzleCount}] ${theme} - ${difficulty}...`);

            const puzzle = await generatePuzzle(openai, theme, difficulty);
            const docRef = await db.collection('puzzles').add(puzzle);

            console.log(`  ✓ Saved to Firestore: ${docRef.id}`);
            console.log(`  ✓ Words placed: ${puzzle.words.length}\n`);

            successCount++;
            logEntries.push({
              success: true,
              theme,
              difficulty,
              puzzleId: docRef.id,
              wordCount: puzzle.words.length
            });

            // Rate limiting: 2 second delay between API calls
            await new Promise(resolve => setTimeout(resolve, 2000));

          } catch (error) {
            console.error(`  ✗ Error: ${error.message}\n`);
            errorCount++;
            logEntries.push({
              success: false,
              theme,
              difficulty,
              error: error.message
            });
          }

          if (successCount + errorCount >= puzzleCount) {
            break;
          }
        }
        if (successCount + errorCount >= puzzleCount) {
          break;
        }
      }
      if (successCount + errorCount >= puzzleCount) {
        break;
      }
    }

    // Summary
    const duration = ((Date.now() - startTime) / 1000).toFixed(1);
    console.log('\n================================');
    console.log('Summary:');
    console.log(`  ✓ Successful: ${successCount}`);
    console.log(`  ✗ Failed: ${errorCount}`);
    console.log(`  ⏱ Duration: ${duration}s`);
    console.log('================================\n');

    // Save log
    fs.writeFileSync(
      'generation-log.json',
      JSON.stringify({
        skipped: false,
        reason: decision.reason,
        logEntries,
        successCount,
        errorCount,
        duration,
        timestamp: new Date().toISOString()
      }, null, 2)
    );

    process.exit(errorCount > 0 ? 1 : 0);

  } catch (error) {
    console.error('\n❌ Fatal error:', error);
    process.exit(1);
  }
}

// Run
main();
