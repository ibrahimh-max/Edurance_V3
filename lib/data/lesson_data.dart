import '../models/lesson.dart';

// ── ALPHABET ──
const List<Lesson> alphabetLessons = [
  Lesson(id: "A", module: "alphabet", title: "A", emoji: "🍎", prompt: "Which word starts with A?", options: ["Apple", "Ball", "Cat", "Dog"]),
  Lesson(id: "B", module: "alphabet", title: "B", emoji: "🐻", prompt: "Which word starts with B?", options: ["Bear", "Apple", "Cat", "Dog"]),
  Lesson(id: "C", module: "alphabet", title: "C", emoji: "🐱", prompt: "Which word starts with C?", options: ["Cat", "Apple", "Bear", "Dog"]),
  Lesson(id: "D", module: "alphabet", title: "D", emoji: "🐶", prompt: "Which word starts with D?", options: ["Dog", "Cat", "Apple", "Bear"]),
  Lesson(id: "E", module: "alphabet", title: "E", emoji: "🐘", prompt: "Which word starts with E?", options: ["Elephant", "Dog", "Fish", "Cat"]),
  Lesson(id: "F", module: "alphabet", title: "F", emoji: "🐟", prompt: "Which word starts with F?", options: ["Fish", "Dog", "Elephant", "Goat"]),
  Lesson(id: "G", module: "alphabet", title: "G", emoji: "🐐", prompt: "Which word starts with G?", options: ["Goat", "Fish", "Elephant", "Horse"]),
  Lesson(id: "H", module: "alphabet", title: "H", emoji: "🐴", prompt: "Which word starts with H?", options: ["Horse", "Goat", "Fish", "Igloo"]),
  Lesson(id: "I", module: "alphabet", title: "I", emoji: "🧊", prompt: "Which word starts with I?", options: ["Igloo", "Horse", "Goat", "Jelly"]),
  Lesson(id: "J", module: "alphabet", title: "J", emoji: "🍇", prompt: "Which word starts with J?", options: ["Jelly", "Igloo", "Horse", "Kite"]),
  Lesson(id: "K", module: "alphabet", title: "K", emoji: "🪁", prompt: "Which word starts with K?", options: ["Kite", "Jelly", "Igloo", "Lion"]),
  Lesson(id: "L", module: "alphabet", title: "L", emoji: "🦁", prompt: "Which word starts with L?", options: ["Lion", "Kite", "Jelly", "Monkey"]),
  Lesson(id: "M", module: "alphabet", title: "M", emoji: "🐒", prompt: "Which word starts with M?", options: ["Monkey", "Lion", "Kite", "Nest"]),
  Lesson(id: "N", module: "alphabet", title: "N", emoji: "🪹", prompt: "Which word starts with N?", options: ["Nest", "Monkey", "Lion", "Owl"]),
  Lesson(id: "O", module: "alphabet", title: "O", emoji: "🦉", prompt: "Which word starts with O?", options: ["Owl", "Nest", "Monkey", "Pig"]),
  Lesson(id: "P", module: "alphabet", title: "P", emoji: "🐷", prompt: "Which word starts with P?", options: ["Pig", "Owl", "Nest", "Queen"]),
  Lesson(id: "Q", module: "alphabet", title: "Q", emoji: "👑", prompt: "Which word starts with Q?", options: ["Queen", "Pig", "Owl", "Rabbit"]),
  Lesson(id: "R", module: "alphabet", title: "R", emoji: "🐰", prompt: "Which word starts with R?", options: ["Rabbit", "Queen", "Pig", "Sun"]),
  Lesson(id: "S", module: "alphabet", title: "S", emoji: "☀️", prompt: "Which word starts with S?", options: ["Sun", "Rabbit", "Queen", "Tree"]),
  Lesson(id: "T", module: "alphabet", title: "T", emoji: "🌳", prompt: "Which word starts with T?", options: ["Tree", "Sun", "Rabbit", "Umbrella"]),
  Lesson(id: "U", module: "alphabet", title: "U", emoji: "☔", prompt: "Which word starts with U?", options: ["Umbrella", "Tree", "Sun", "Van"]),
  Lesson(id: "V", module: "alphabet", title: "V", emoji: "🚐", prompt: "Which word starts with V?", options: ["Van", "Umbrella", "Tree", "Water"]),
  Lesson(id: "W", module: "alphabet", title: "W", emoji: "💧", prompt: "Which word starts with W?", options: ["Water", "Van", "Umbrella", "Xylophone"]),
  Lesson(id: "X", module: "alphabet", title: "X", emoji: "🎹", prompt: "Which word starts with X?", options: ["Xylophone", "Water", "Van", "Yak"]),
  Lesson(id: "Y", module: "alphabet", title: "Y", emoji: "🐂", prompt: "Which word starts with Y?", options: ["Yak", "Xylophone", "Water", "Zebra"]),
  Lesson(id: "Z", module: "alphabet", title: "Z", emoji: "🦓", prompt: "Which word starts with Z?", options: ["Zebra", "Yak", "Xylophone", "Ant"]),
];

// ── NUMBERS ──
final List<Lesson> numberLessons = List.generate(30, (index) {
  final num = index + 1;
  // Generate options that include the correct number and 3 other numbers
  final opts = [
    num.toString(),
    (num == 1 ? 2 : num - 1).toString(),
    (num == 30 ? 29 : num + 1).toString(),
    (num + 2).toString()
  ];
  return Lesson(
    id: num.toString(),
    module: "numbers",
    title: num.toString(),
    emoji: "🔢",
    prompt: "Which group shows $num?",
    options: opts,
  );
});

// ── COLORS ──
const List<Lesson> colorLessons = [
  Lesson(id: "red", module: "colors", title: "Red", emoji: "🟥", prompt: "Which object is red?", options: ["Apple", "Sky", "Grass", "Banana"]),
  Lesson(id: "blue", module: "colors", title: "Blue", emoji: "🟦", prompt: "Which object is blue?", options: ["Sky", "Apple", "Grass", "Banana"]),
  Lesson(id: "yellow", module: "colors", title: "Yellow", emoji: "🟨", prompt: "Which object is yellow?", options: ["Banana", "Sky", "Grass", "Apple"]),
  Lesson(id: "green", module: "colors", title: "Green", emoji: "🟩", prompt: "Which object is green?", options: ["Grass", "Sky", "Banana", "Apple"]),
  Lesson(id: "orange", module: "colors", title: "Orange", emoji: "🟧", prompt: "Which object is orange?", options: ["Orange", "Grapes", "Milk", "Coal"]),
  Lesson(id: "purple", module: "colors", title: "Purple", emoji: "🟪", prompt: "Which object is purple?", options: ["Grapes", "Orange", "Milk", "Coal"]),
  Lesson(id: "black", module: "colors", title: "Black", emoji: "⬛", prompt: "Which object is black?", options: ["Coal", "Orange", "Grapes", "Milk"]),
  Lesson(id: "white", module: "colors", title: "White", emoji: "⬜", prompt: "Which object is white?", options: ["Milk", "Orange", "Grapes", "Coal"]),
  Lesson(id: "brown", module: "colors", title: "Brown", emoji: "🟫", prompt: "Which object is brown?", options: ["Chocolate", "Pig", "Snow", "Leaves"]),
  Lesson(id: "pink", module: "colors", title: "Pink", emoji: "🩷", prompt: "Which object is pink?", options: ["Pig", "Chocolate", "Snow", "Leaves"]),
];

// ── SHAPES ──
const List<Lesson> shapeLessons = [
  Lesson(id: "circle", module: "shapes", title: "Circle", emoji: "⚪", prompt: "Which shape is round?", options: ["Circle", "Square", "Triangle", "Rectangle"]),
  Lesson(id: "square", module: "shapes", title: "Square", emoji: "🟩", prompt: "Which shape has 4 equal sides?", options: ["Square", "Circle", "Triangle", "Rectangle"]),
  Lesson(id: "triangle", module: "shapes", title: "Triangle", emoji: "🔺", prompt: "Which shape has 3 sides?", options: ["Triangle", "Square", "Circle", "Rectangle"]),
  Lesson(id: "rectangle", module: "shapes", title: "Rectangle", emoji: "🟫", prompt: "Which shape is long and has 4 sides?", options: ["Rectangle", "Square", "Circle", "Triangle"]),
  Lesson(id: "star", module: "shapes", title: "Star", emoji: "⭐", prompt: "Which shape twinkles in the sky?", options: ["Star", "Circle", "Triangle", "Rectangle"]),
  Lesson(id: "oval", module: "shapes", title: "Oval", emoji: "🥚", prompt: "Which shape looks like an egg?", options: ["Oval", "Square", "Triangle", "Rectangle"]),
  Lesson(id: "heart", module: "shapes", title: "Heart", emoji: "❤️", prompt: "Which shape means love?", options: ["Heart", "Square", "Triangle", "Rectangle"]),
  Lesson(id: "diamond", module: "shapes", title: "Diamond", emoji: "♦️", prompt: "Which shape is a kite?", options: ["Diamond", "Circle", "Triangle", "Rectangle"]),
  Lesson(id: "pentagon", module: "shapes", title: "Pentagon", emoji: "⬟", prompt: "Which shape has 5 sides?", options: ["Pentagon", "Square", "Triangle", "Rectangle"]),
  Lesson(id: "hexagon", module: "shapes", title: "Hexagon", emoji: "⬢", prompt: "Which shape has 6 sides?", options: ["Hexagon", "Square", "Triangle", "Rectangle"]),
];

// ── RHYMES ──
const List<Lesson> rhymeLessons = [
  Lesson(id: "twinkle_line_1", module: "rhymes", title: "Twinkle Twinkle", emoji: "⭐", prompt: "Twinkle, twinkle, little star", options: []),
  Lesson(id: "twinkle_line_2", module: "rhymes", title: "Twinkle Twinkle", emoji: "⭐", prompt: "How I wonder what you are", options: []),
  Lesson(id: "twinkle_line_3", module: "rhymes", title: "Twinkle Twinkle", emoji: "⭐", prompt: "Up above the world so high", options: []),
  Lesson(id: "twinkle_line_4", module: "rhymes", title: "Twinkle Twinkle", emoji: "⭐", prompt: "Like a diamond in the sky", options: []),
];
