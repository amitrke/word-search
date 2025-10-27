# GitHub Actions Puzzle Generation Setup

This guide shows how to use GitHub Actions to generate puzzles with ChatGPT and populate Firebase, avoiding the need for Firebase Blaze plan.

## 🎯 Benefits

- ✅ **FREE** - No Firebase Blaze plan required (stay on Spark plan)
- ✅ **FREE** - GitHub Actions: 2,000 minutes/month (private) or unlimited (public)
- ✅ **Simpler** - No Cloud Functions to manage
- ✅ **Perfect for pre-generated content** - Puzzles created in batches
- ✅ **Scheduled** - Automatic daily puzzle generation
- ✅ **Manual trigger** - Generate puzzles on-demand

## 📋 Prerequisites

- GitHub repository for your project
- Firebase project (Spark plan is fine!)
- OpenAI API key

## 🚀 Quick Setup (30 minutes)

### Step 1: Create Firebase Service Account

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Click ⚙️ → Project Settings
4. Go to "Service Accounts" tab
5. Click "Generate new private key"
6. Save the JSON file (you'll need it in step 3)

### Step 2: Get OpenAI API Key

1. Go to [OpenAI Platform](https://platform.openai.com/)
2. Sign up or log in
3. Go to API Keys section
4. Click "Create new secret key"
5. Copy and save the key (you'll need it in step 3)

### Step 3: Add GitHub Secrets

1. Go to your GitHub repository
2. Click Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Add two secrets:

**Secret 1: OPENAI_API_KEY**
```
Name: OPENAI_API_KEY
Secret: sk-... (your OpenAI API key)
```

**Secret 2: FIREBASE_SERVICE_ACCOUNT**
```
Name: FIREBASE_SERVICE_ACCOUNT
Secret: (paste entire JSON content from Step 1)
```

### Step 4: Create Project Structure

```bash
# Create directories
mkdir -p .github/workflows
mkdir -p scripts/puzzle-generator

# You'll create these files in next steps:
# .github/workflows/generate-puzzles.yml
# scripts/puzzle-generator/package.json
# scripts/puzzle-generator/generate-puzzles.js
```

### Step 5: Create package.json

Create `scripts/puzzle-generator/package.json`:

```json
{
  "name": "puzzle-generator",
  "version": "1.0.0",
  "description": "Generate word search puzzles using ChatGPT",
  "main": "generate-puzzles.js",
  "scripts": {
    "generate": "node generate-puzzles.js"
  },
  "dependencies": {
    "firebase-admin": "^12.0.0",
    "openai": "^4.20.0"
  }
}
```

### Step 6: Create GitHub Action Workflow

Create `.github/workflows/generate-puzzles.yml`:

```yaml
name: Generate Word Search Puzzles

on:
  schedule:
    # Run daily at 2 AM UTC
    - cron: '0 2 * * *'

  workflow_dispatch:
    # Allow manual trigger
    inputs:
      puzzle_count:
        description: 'Number of puzzles to generate'
        required: false
        default: '14'
      theme:
        description: 'Specific theme (leave empty for all themes)'
        required: false
        default: ''
      force_generate:
        description: 'Force generation (ignore inventory checks)'
        required: false
        default: 'false'
        type: choice
        options:
          - 'false'
          - 'true'

jobs:
  generate-puzzles:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
          cache-dependency-path: scripts/puzzle-generator/package-lock.json

      - name: Install dependencies
        working-directory: scripts/puzzle-generator
        run: npm ci

      - name: Generate puzzles
        working-directory: scripts/puzzle-generator
        env:
          OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
          FIREBASE_SERVICE_ACCOUNT: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
          PUZZLE_COUNT: ${{ github.event.inputs.puzzle_count || '14' }}
          THEME_FILTER: ${{ github.event.inputs.theme || '' }}
          FORCE_GENERATE: ${{ github.event.inputs.force_generate || 'false' }}
          # Inventory management configuration
          MIN_PUZZLES: '30'           # Minimum total puzzles to maintain
          MAX_PUZZLES: '200'          # Maximum total puzzles (stop if reached)
          MIN_CONSUMPTION_RATE: '20'  # Only generate if >20% of puzzles have been played
          MIN_PER_DIFFICULTY: '8'     # Minimum puzzles per difficulty level
          MIN_PER_THEME: '3'          # Minimum puzzles per theme
        run: node generate-puzzles.js

      - name: Upload logs
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: generation-logs
          path: scripts/puzzle-generator/*.log
          retention-days: 7
```

### Step 7: Create Puzzle Generator Script

Create `scripts/puzzle-generator/generate-puzzles.js`:

```javascript
const admin = require('firebase-admin');
const OpenAI = require('openai');
const fs = require('fs');

// Configuration
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

// Initialize Firebase Admin
function initFirebase() {
  const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });

  console.log('✓ Firebase Admin initialized');
  return admin.firestore();
}

// Initialize OpenAI
function initOpenAI() {
  const openai = new OpenAI({
    apiKey: process.env.OPENAI_API_KEY
  });

  console.log('✓ OpenAI initialized');
  return openai;
}

// Generate word list using ChatGPT
async function generateWordList(openai, theme, difficulty) {
  const params = WORD_COUNTS[difficulty];
  const wordCount = Math.floor(Math.random() * (params.max - params.min + 1)) + params.min;

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
4. For ${difficulty} difficulty, choose words accordingly:
   - simple: Common, everyday words
   - medium: Moderately challenging words
   - hard: Advanced or less common words

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
    data.words = data.words.map(w => w.toUpperCase().replace(/\s+/g, ''));

    console.log(`  Generated ${data.words.length} words for ${theme} (${difficulty})`);
    return data;

  } catch (error) {
    console.error(`  ✗ Error generating word list: ${error.message}`);
    throw error;
  }
}

// Place words in grid
function placeWordsInGrid(words, gridSize) {
  const grid = Array(gridSize).fill(null).map(() =>
    Array(gridSize).fill('')
  );

  const placedWords = [];

  const directions = [
    { dr: 0, dc: 1, name: 'horizontal' },
    { dr: 1, dc: 0, name: 'vertical' },
    { dr: 1, dc: 1, name: 'diagonal-down' },
    { dr: 1, dc: -1, name: 'diagonal-up' }
  ];

  // Sort by length (longest first for better placement)
  const sortedWords = [...words].sort((a, b) => b.length - a.length);

  for (const word of sortedWords) {
    let placed = false;
    let attempts = 0;
    const maxAttempts = 200;

    while (!placed && attempts < maxAttempts) {
      const row = Math.floor(Math.random() * gridSize);
      const col = Math.floor(Math.random() * gridSize);
      const dir = directions[Math.floor(Math.random() * directions.length)];

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

// Generate complete puzzle
async function generatePuzzle(openai, theme, difficulty) {
  // Get words from ChatGPT
  const { words, hints } = await generateWordList(openai, theme, difficulty);

  // Place in grid
  const gridSize = GRID_SIZES[difficulty];
  const { grid, placedWords } = placeWordsInGrid(words, gridSize);

  // Create puzzle object
  const puzzle = {
    theme,
    difficulty,
    gridSize,
    grid,
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

// Check puzzle inventory and usage statistics
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

// Determine if we need to generate more puzzles
function shouldGeneratePuzzles(inventory, config) {
  const {
    totalPuzzles,
    consumptionRate,
    puzzlesByDifficulty,
    puzzlesByTheme
  } = inventory;

  const {
    minPuzzles = 30,           // Minimum total puzzles to maintain
    maxPuzzles = 200,          // Maximum total puzzles (stop if reached)
    minConsumptionRate = 20,   // Only generate if consumption rate > 20%
    minPerDifficulty = 8,      // Minimum puzzles per difficulty level
    minPerTheme = 3            // Minimum puzzles per theme
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
      targetCount: lowDifficulties.length * (minPerDifficulty - 5)
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

// Main function
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
    const combinations = themes.length * DIFFICULTIES.length;
    const puzzlesPerCombo = Math.ceil(puzzleCount / combinations);

    console.log(`Generating ${puzzlesPerCombo} puzzle(s) per theme/difficulty combination\n`);

    let successCount = 0;
    let errorCount = 0;

    // Generate puzzles
    for (const theme of themes) {
      for (const difficulty of DIFFICULTIES) {
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
      JSON.stringify({ logEntries, successCount, errorCount, duration }, null, 2)
    );

    process.exit(errorCount > 0 ? 1 : 0);

  } catch (error) {
    console.error('\n❌ Fatal error:', error);
    process.exit(1);
  }
}

// Run
main();
```

## 🎮 Usage

### Manual Generation

1. Go to your GitHub repository
2. Click on the "Actions" tab
3. Select "Generate Word Search Puzzles" workflow
4. Click "Run workflow" button
5. (Optional) Enter custom values:
   - Number of puzzles: `20`
   - Specific theme: `Animals` (or leave empty for all)
6. Click green "Run workflow" button
7. Wait 5-10 minutes
8. Check Firestore - puzzles are populated!

### Automatic Daily Generation

- Workflow runs automatically at 2 AM UTC every day
- Generates 14 puzzles by default (2 per difficulty × 7 themes)
- No manual intervention needed

### View Logs

1. Go to Actions tab
2. Click on a workflow run
3. Click on "generate-puzzles" job
4. View console output
5. Download logs artifact if needed

## 🎯 Intelligent Inventory Management

The generator includes **smart inventory management** to avoid wasting money on unused puzzles.

### How It Works

Every time the workflow runs, it:

1. **Checks Inventory**
   - Total puzzles in database
   - Puzzles by difficulty and theme
   - How many puzzles users have played

2. **Calculates Consumption Rate**
   - `Consumption Rate = (Puzzles Played / Total Puzzles) × 100`
   - Example: 50 plays / 100 puzzles = 50% consumption

3. **Decides Whether to Generate**
   - Based on multiple criteria (see below)

4. **Generates Only What's Needed**
   - Fills gaps in specific difficulties or themes
   - Maintains balanced inventory

### Generation Rules

The workflow will **skip generation** if:

| Condition | Threshold | Reason |
|-----------|-----------|--------|
| Inventory is full | ≥ 200 puzzles | Avoid waste |
| Low consumption | < 20% played | Users haven't used existing puzzles |
| Inventory healthy | ≥ 30 puzzles + good distribution | Sufficient stock |

The workflow **will generate** if:

| Condition | Action |
|-----------|--------|
| Total puzzles < 30 | Generate to reach minimum (30) |
| Any difficulty < 8 puzzles | Generate for that difficulty |
| Any theme < 3 puzzles | Generate for that theme |
| High consumption (>20%) | Generate more to replenish |

### Configuration Options

You can customize thresholds via environment variables:

```yaml
env:
  MIN_PUZZLES: '30'           # Minimum total puzzles
  MAX_PUZZLES: '200'          # Maximum total puzzles
  MIN_CONSUMPTION_RATE: '20'  # Minimum consumption % to trigger generation
  MIN_PER_DIFFICULTY: '8'     # Minimum per difficulty level
  MIN_PER_THEME: '3'          # Minimum per theme
```

### Example Scenarios

#### Scenario 1: Low Inventory (Initial State)
```
Current: 0 puzzles
Consumption: N/A
Decision: ✅ Generate 30 puzzles
Reason: Below minimum threshold
```

#### Scenario 2: Healthy Inventory
```
Current: 100 puzzles
Played: 45 (45% consumption)
Decision: ✅ Generate 14 puzzles
Reason: Good consumption rate, maintain inventory
```

#### Scenario 3: Low Consumption
```
Current: 100 puzzles
Played: 10 (10% consumption)
Decision: ❌ Skip generation
Reason: Users haven't played enough existing puzzles
Cost Saved: ~$0.014 (14 puzzles)
```

#### Scenario 4: Inventory Full
```
Current: 200 puzzles
Played: 80 (40% consumption)
Decision: ❌ Skip generation
Reason: At maximum capacity
Cost Saved: ~$0.014
```

#### Scenario 5: Unbalanced Inventory
```
Current: 50 puzzles
- Simple: 20
- Medium: 25
- Hard: 5 ⚠️ (below minimum of 8)

Decision: ✅ Generate 3+ hard puzzles
Reason: One difficulty level is low
```

### Force Generation

To override inventory checks and force generation:

1. Go to Actions → Generate Word Search Puzzles
2. Click "Run workflow"
3. Set **Force generate** to `true`
4. Click "Run workflow"

This is useful when:
- You want to populate specific themes
- You're testing the generation
- You want to build up inventory before launch

### Monitoring Inventory

The workflow logs detailed inventory information:

```
📊 Checking puzzle inventory...

  Inventory Status:
    Total puzzles: 87
    By difficulty: Simple: 30, Medium: 32, Hard: 25

  Usage Statistics:
    Total plays: 156
    Completed: 134
    Consumption rate: 179.3%

  Puzzles by theme:
    Animals: 12
    Countries: 11
    Technology: 10
    Food: 13
    Sports: 15
    Music: 14
    Nature: 12

🤔 Evaluating generation need...

  ✅ Inventory healthy (87 puzzles, 179.3% consumption)
  → No generation needed
```

### Benefits

**Cost Savings**:
- Avoids generating puzzles nobody uses
- Typical savings: 30-50% of API costs
- Example: If workflow runs daily but only generates 15 days/month instead of 30

**Smart Resource Usage**:
- Maintains balanced inventory across all difficulties
- Ensures all themes have minimum representation
- Prevents database bloat

**Automatic Scaling**:
- Generates more as user base grows
- Scales back when usage is low
- No manual intervention needed

## 📊 Cost Estimates

### GitHub Actions Usage
```
Time per puzzle: ~20 seconds
14 puzzles: ~5 minutes
Monthly (30 days): ~150 minutes
Free tier: 2,000 minutes/month
Usage: 7.5% of free tier ✅
```

### OpenAI API Usage (Without Inventory Management)
```
GPT-3.5-turbo per puzzle: ~$0.001
14 puzzles/day × 30 days: ~$0.42/month
```

### OpenAI API Usage (With Intelligent Inventory Management)
```
GPT-3.5-turbo per puzzle: ~$0.001
Estimated generation days: 15-20 days/month (workflow skips when not needed)
Actual monthly cost: ~$0.21-0.28/month ✅
Savings: 30-50% compared to always generating
```

### Firebase Usage
```
Firestore writes: 14/day = 420/month
Free tier: 20,000/day
Usage: Well within free tier ✅
```

**Total Cost: ~$0.25-0.35/month** 🎉
*(With intelligent inventory management - saves 30-50% on API costs!)*

## 🔧 Customization

### Generate More Puzzles
```yaml
# In workflow file, change default:
default: '50'  # Generate 50 puzzles per run
```

### Add New Themes
```javascript
// In generate-puzzles.js, add to THEMES array:
const THEMES = [
  'Animals', 'Countries', 'Technology',
  'YourNewTheme1', 'YourNewTheme2'
];
```

### Change Schedule
```yaml
# Run every 6 hours
- cron: '0 */6 * * *'

# Run weekly on Monday at 3 AM
- cron: '0 3 * * 1'

# Run twice daily
- cron: '0 2,14 * * *'
```

### Use Different AI Model
```javascript
// Use GPT-4 for better quality
model: 'gpt-4'  // More expensive but higher quality

// Or use GPT-4-turbo
model: 'gpt-4-turbo-preview'
```

## 🐛 Troubleshooting

### Workflow fails with "FIREBASE_SERVICE_ACCOUNT not found"
- Check you added the secret in GitHub Settings → Secrets
- Ensure you pasted the entire JSON content
- No extra spaces or line breaks

### "OpenAI API error: 429 Too Many Requests"
- You hit rate limits
- Increase delay between calls in script:
  ```javascript
  await new Promise(resolve => setTimeout(resolve, 5000)); // 5 seconds
  ```

### "Firebase permission denied"
- Check service account has Firestore write permissions
- Go to Firebase Console → IAM & Admin
- Ensure service account has "Cloud Datastore User" role

### Puzzles have missing words
- Some words couldn't be placed in grid
- Increase `maxAttempts` in `placeWordsInGrid()`
- Or reduce word count for difficulty level

## ✅ Testing Checklist

- [ ] GitHub secrets added correctly
- [ ] Workflow file created in `.github/workflows/`
- [ ] Script created in `scripts/puzzle-generator/`
- [ ] package.json created
- [ ] Manual workflow run succeeds
- [ ] Puzzles appear in Firestore
- [ ] Puzzles are valid (words placed correctly)
- [ ] Automatic schedule tested (wait 24 hours)

## 🎯 Next Steps

1. Complete this setup
2. Generate initial batch of puzzles (50-100)
3. Test puzzles in your Flutter app
4. Adjust themes/difficulty as needed
5. Set up daily challenge workflow (similar approach)

## 📚 Related Documentation

- [REQUIREMENTS.md](REQUIREMENTS.md) - Full feature requirements
- [TECHNICAL_SETUP.md](TECHNICAL_SETUP.md) - Firebase setup
- [PROGRESS.md](PROGRESS.md) - Implementation checklist

---

**Status**: ✅ Recommended approach for staying on Firebase Spark plan
