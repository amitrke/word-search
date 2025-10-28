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

// Level-based configuration (30 levels)
const LEVEL_CONFIG = [
  // Levels 1-5: Beginner (5x5 to 7x7, horizontal/vertical only)
  { level: 1, gridSize: 5, minWords: 3, maxWords: 4, difficulty: 'simple', directions: ['horizontal', 'vertical'] },
  { level: 2, gridSize: 5, minWords: 4, maxWords: 5, difficulty: 'simple', directions: ['horizontal', 'vertical'] },
  { level: 3, gridSize: 6, minWords: 4, maxWords: 5, difficulty: 'simple', directions: ['horizontal', 'vertical'] },
  { level: 4, gridSize: 6, minWords: 5, maxWords: 6, difficulty: 'simple', directions: ['horizontal', 'vertical'] },
  { level: 5, gridSize: 7, minWords: 5, maxWords: 6, difficulty: 'simple', directions: ['horizontal', 'vertical'] },

  // Levels 6-10: Easy (8x8, add diagonals)
  { level: 6, gridSize: 8, minWords: 6, maxWords: 7, difficulty: 'simple', directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'] },
  { level: 7, gridSize: 8, minWords: 6, maxWords: 8, difficulty: 'simple', directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'] },
  { level: 8, gridSize: 8, minWords: 7, maxWords: 8, difficulty: 'simple', directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'] },
  { level: 9, gridSize: 8, minWords: 7, maxWords: 9, difficulty: 'simple', directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'] },
  { level: 10, gridSize: 8, minWords: 8, maxWords: 10, difficulty: 'simple', directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'] },

  // Levels 11-15: Medium (10x10)
  { level: 11, gridSize: 10, minWords: 8, maxWords: 10, difficulty: 'medium', directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'] },
  { level: 12, gridSize: 10, minWords: 9, maxWords: 11, difficulty: 'medium', directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'] },
  { level: 13, gridSize: 10, minWords: 10, maxWords: 12, difficulty: 'medium', directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'] },
  { level: 14, gridSize: 10, minWords: 10, maxWords: 12, difficulty: 'medium', directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'] },
  { level: 15, gridSize: 10, minWords: 11, maxWords: 13, difficulty: 'medium', directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'] },

  // Levels 16-20: Hard (12x12)
  { level: 16, gridSize: 12, minWords: 10, maxWords: 12, difficulty: 'hard', directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'] },
  { level: 17, gridSize: 12, minWords: 11, maxWords: 13, difficulty: 'hard', directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'] },
  { level: 18, gridSize: 12, minWords: 12, maxWords: 14, difficulty: 'hard', directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'] },
  { level: 19, gridSize: 12, minWords: 13, maxWords: 15, difficulty: 'hard', directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'] },
  { level: 20, gridSize: 12, minWords: 14, maxWords: 16, difficulty: 'hard', directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'] },

  // Levels 21-25: Very Hard (15x15)
  { level: 21, gridSize: 15, minWords: 12, maxWords: 15, difficulty: 'hard', directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'] },
  { level: 22, gridSize: 15, minWords: 13, maxWords: 16, difficulty: 'hard', directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'] },
  { level: 23, gridSize: 15, minWords: 14, maxWords: 17, difficulty: 'hard', directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'] },
  { level: 24, gridSize: 15, minWords: 15, maxWords: 18, difficulty: 'hard', directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'] },
  { level: 25, gridSize: 15, minWords: 16, maxWords: 19, difficulty: 'hard', directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'] },

  // Levels 26-30: Expert (15x15, maximum difficulty)
  { level: 26, gridSize: 15, minWords: 16, maxWords: 19, difficulty: 'hard', directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'] },
  { level: 27, gridSize: 15, minWords: 17, maxWords: 20, difficulty: 'hard', directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'] },
  { level: 28, gridSize: 15, minWords: 18, maxWords: 21, difficulty: 'hard', directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'] },
  { level: 29, gridSize: 15, minWords: 19, maxWords: 22, difficulty: 'hard', directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'] },
  { level: 30, gridSize: 15, minWords: 20, maxWords: 23, difficulty: 'hard', directions: ['horizontal', 'vertical', 'diagonal-down', 'diagonal-up'] },
];

// Backwards compatibility
const DIFFICULTIES = ['simple', 'medium', 'hard'];

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

async function generateWordList(openai, theme, levelConfig) {
  const wordCount = Math.floor(Math.random() * (levelConfig.maxWords - levelConfig.minWords + 1)) + levelConfig.minWords;

  const difficultyGuidance = {
    simple: 'common, everyday words that are easy to recognize',
    medium: 'moderately challenging words with some variety',
    hard: 'advanced vocabulary and less common words'
  };

  const prompt = `Generate a word search puzzle with the following specifications:

Theme: ${theme}
Level: ${levelConfig.level} (${levelConfig.difficulty} difficulty)
Grid Size: ${levelConfig.gridSize}x${levelConfig.gridSize}
Number of words: ${wordCount}

Requirements:
1. Provide exactly ${wordCount} words related to "${theme}"
2. Each word should have a brief hint (one sentence, under 100 characters)
3. Words should be:
   - Appropriate for all ages
   - Clearly related to the theme
   - Varied in length (3-${Math.min(12, levelConfig.gridSize)} letters)
   - Single words (no spaces or hyphens)
   - English language
   - ${difficultyGuidance[levelConfig.difficulty]}
4. Ensure diversity in word choices

Return ONLY valid JSON (no markdown, no explanations) in this exact format:
{
  "words": ["word1", "word2", ...],
  "hints": ["hint for word1", "hint for word2", ...]
}`;

  try {
    const response = await openai.chat.completions.create({
      model: 'gpt-4o-mini',
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

    console.log(`  Generated ${data.words.length} words for ${theme} (Level ${levelConfig.level})`);
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

function placeWordsInGrid(words, levelConfig) {
  const gridSize = levelConfig.gridSize;
  const grid = Array(gridSize).fill(null).map(() =>
    Array(gridSize).fill('')
  );

  const placedWords = [];

  // Filter directions based on level config
  const allowedDirections = DIRECTIONS.filter(dir =>
    levelConfig.directions.includes(dir.name)
  );

  // Sort by length (longest first for better placement)
  const sortedWords = [...words].sort((a, b) => b.length - a.length);

  for (const word of sortedWords) {
    let placed = false;
    let attempts = 0;
    const maxAttempts = 200;

    while (!placed && attempts < maxAttempts) {
      const row = Math.floor(Math.random() * gridSize);
      const col = Math.floor(Math.random() * gridSize);
      const dir = allowedDirections[Math.floor(Math.random() * allowedDirections.length)];

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

async function generatePuzzle(openai, theme, levelConfig) {
  // Get words from ChatGPT
  const { words, hints } = await generateWordList(openai, theme, levelConfig);

  // Place in grid
  const { grid, placedWords } = placeWordsInGrid(words, levelConfig);

  // Convert 2D grid to array of strings (Firestore doesn't support nested arrays)
  const gridStrings = grid.map(row => row.join(''));

  // Create puzzle object
  const puzzle = {
    theme,
    difficulty: levelConfig.difficulty,  // For backward compatibility
    level: levelConfig.level,            // New level field
    gridSize: levelConfig.gridSize,
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
    tags: [theme.toLowerCase(), levelConfig.difficulty, `level${levelConfig.level}`],
    version: '2.0'  // Updated version for level-based system
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
    const puzzleCount = decision.targetCount || parseInt(process.env.PUZZLE_COUNT || '30');
    const themeFilter = process.env.THEME_FILTER || '';
    const levelFilter = process.env.LEVEL_FILTER || ''; // e.g., "1-5" for levels 1-5

    const themes = decision.focusThemes || (themeFilter ? [themeFilter] : THEMES);

    // Parse level filter (e.g., "1-5" or "10" or empty for all)
    let targetLevels = LEVEL_CONFIG;
    if (levelFilter) {
      if (levelFilter.includes('-')) {
        const [start, end] = levelFilter.split('-').map(Number);
        targetLevels = LEVEL_CONFIG.filter(lc => lc.level >= start && lc.level <= end);
      } else {
        const level = parseInt(levelFilter);
        targetLevels = LEVEL_CONFIG.filter(lc => lc.level === level);
      }
    }

    console.log(`\nConfiguration:`);
    console.log(`  Target puzzles: ${puzzleCount}`);
    console.log(`  Themes: ${themes.join(', ')}`);
    console.log(`  Levels: ${targetLevels.map(l => l.level).join(', ')}`);
    console.log(`  Reason: ${decision.reason}\n`);

    // Calculate puzzles per theme/level
    const combinations = themes.length * targetLevels.length;
    const puzzlesPerCombo = Math.max(1, Math.ceil(puzzleCount / combinations));

    console.log(`Generating ${puzzlesPerCombo} puzzle(s) per theme/level combination\n`);

    let successCount = 0;
    let errorCount = 0;

    // Generate puzzles
    for (const theme of themes) {
      for (const levelConfig of targetLevels) {
        for (let i = 0; i < puzzlesPerCombo; i++) {
          try {
            console.log(`[${successCount + errorCount + 1}/${puzzleCount}] ${theme} - Level ${levelConfig.level}...`);

            const puzzle = await generatePuzzle(openai, theme, levelConfig);
            const docRef = await db.collection('puzzles').add(puzzle);

            console.log(`  ✓ Saved to Firestore: ${docRef.id}`);
            console.log(`  ✓ Grid: ${levelConfig.gridSize}x${levelConfig.gridSize}`);
            console.log(`  ✓ Words placed: ${puzzle.words.length}\n`);

            successCount++;
            logEntries.push({
              success: true,
              theme,
              level: levelConfig.level,
              difficulty: levelConfig.difficulty,
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
              level: levelConfig.level,
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
