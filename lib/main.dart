import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QuoteApp());
}

// ═══════════════════════════ DATA ═══════════════════════════

class Quote {
  final String text;
  final String author;
  final String category;
  final List<String> moods;
  const Quote(this.text, this.author, this.category, [this.moods = const []]);
  String get key => '$text|$author';
  bool get isQuran => category == 'Quran';
}

class CategoryInfo {
  final String name;
  final IconData icon;
  final List<Color> colors;
  final String blurb;
  const CategoryInfo(this.name, this.icon, this.colors, this.blurb);
}

const List<CategoryInfo> categoryInfos = [
  CategoryInfo('Quran', Icons.menu_book, [Color(0xFF0F766E), Color(0xFF34D399)],
      'Verses of comfort, hope and guidance'),
  CategoryInfo('Faith & Hadith', Icons.mosque, [Color(0xFF1E3A8A), Color(0xFF60A5FA)],
      'Sayings of the Prophet and lessons of faith'),
  CategoryInfo('Hope & Patience', Icons.wb_sunny, [Color(0xFFF59E0B), Color(0xFFFCD34D)],
      'For the days when you need strength'),
  CategoryInfo('Motivation', Icons.bolt, [Color(0xFFEF4444), Color(0xFFF97316)],
      'Get up, keep going'),
  CategoryInfo('Success', Icons.emoji_events, [Color(0xFF7C3AED), Color(0xFFA78BFA)],
      'Small steps, big goals'),
  CategoryInfo('Wisdom', Icons.psychology, [Color(0xFF475569), Color(0xFF94A3B8)],
      'Timeless words to think about'),
  CategoryInfo('Life', Icons.spa, [Color(0xFF059669), Color(0xFF6EE7B7)],
      'On living well'),
  CategoryInfo('Love & Friendship', Icons.favorite, [Color(0xFFDB2777), Color(0xFFF9A8D4)],
      'Kindness, love and the people we hold dear'),
  CategoryInfo('Gratitude', Icons.volunteer_activism, [Color(0xFF0891B2), Color(0xFF67E8F9)],
      'Count your blessings'),
  CategoryInfo('Poetry & Soul', Icons.auto_stories, [Color(0xFF9333EA), Color(0xFFE879F9)],
      'Rumi, Iqbal, Gibran, Tagore and more'),
];

class Mood {
  final String name;
  final IconData icon;
  final List<Color> colors;
  final String intro;
  final bool sensitive;
  const Mood(this.name, this.icon, this.colors, this.intro, {this.sensitive = false});
}

const List<Mood> moods = [
  Mood('Happy', Icons.sentiment_very_satisfied, [Color(0xFFF7971E), Color(0xFFFFB347)],
      'So glad you\'re feeling good! Let\'s make it even brighter.'),
  Mood('Grateful', Icons.volunteer_activism, [Color(0xFF11998E), Color(0xFF38EF7D)],
      'Gratitude is a beautiful place to be.'),
  Mood('Sad', Icons.sentiment_dissatisfied, [Color(0xFF4568DC), Color(0xFF8E9EEF)],
      'I\'m sorry you\'re feeling sad. It\'s okay to feel this way. Here are some words for your heart.',
      sensitive: true),
  Mood('Anxious', Icons.air, [Color(0xFF00B4DB), Color(0xFF0083B0)],
      'Take a slow breath. In this moment, you are safe.'),
  Mood('Stressed', Icons.speed, [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
      'That sounds like a lot. One step at a time.'),
  Mood('Angry', Icons.local_fire_department, [Color(0xFFFF512F), Color(0xFFDD2476)],
      'It\'s okay to be angry. Let\'s cool down together.'),
  Mood('Lonely', Icons.person_outline, [Color(0xFF667EEA), Color(0xFF764BA2)],
      'You are not alone, even when it feels that way.',
      sensitive: true),
  Mood('Tired', Icons.bedtime, [Color(0xFF606C88), Color(0xFF3F4C6B)],
      'You\'ve been carrying a lot. Rest is not weakness.'),
  Mood('Low', Icons.cloud, [Color(0xFF373B44), Color(0xFF4286F4)],
      'I\'m here with you. This feeling will not last forever.',
      sensitive: true),
];

const List<Quote> allQuotes = [
  // ───────── Quran (simple English renderings of the meanings) ─────────
  Quote('So surely, with hardship comes ease. Surely, with hardship comes ease.', 'Quran 94:5-6', 'Quran', ['Sad', 'Stressed', 'Low', 'Anxious', 'Tired']),
  Quote('Allah does not burden a soul beyond what it can bear.', 'Quran 2:286', 'Quran', ['Stressed', 'Tired', 'Anxious', 'Low']),
  Quote('Indeed, in the remembrance of Allah do hearts find rest.', 'Quran 13:28', 'Quran', ['Anxious', 'Stressed', 'Lonely', 'Sad']),
  Quote('And whoever relies on Allah, He is enough for them.', 'Quran 65:3', 'Quran', ['Anxious', 'Stressed', 'Low']),
  Quote('Do not lose heart and do not grieve, for you will be superior if you are true believers.', 'Quran 3:139', 'Quran', ['Sad', 'Low']),
  Quote('Do not despair of the mercy of Allah.', 'Quran 39:53', 'Quran', ['Low', 'Sad']),
  Quote('Your Lord has not abandoned you, nor has He disliked you.', 'Quran 93:3', 'Quran', ['Lonely', 'Low', 'Sad']),
  Quote('And your Lord is going to give you, and you will be satisfied.', 'Quran 93:5', 'Quran', ['Low', 'Tired', 'Sad']),
  Quote('So remember Me; I will remember you. And be grateful to Me.', 'Quran 2:152', 'Quran', ['Lonely', 'Grateful']),
  Quote('If you are grateful, I will surely give you more.', 'Quran 14:7', 'Quran', ['Grateful', 'Happy']),
  Quote('We are closer to a person than their jugular vein.', 'Quran 50:16', 'Quran', ['Lonely']),
  Quote('When My servants ask you about Me, indeed I am near. I respond to the call of the one who calls upon Me.', 'Quran 2:186', 'Quran', ['Lonely', 'Anxious', 'Sad']),
  Quote('Do not despair of relief from Allah.', 'Quran 12:87', 'Quran', ['Low', 'Anxious']),
  Quote('Do not grieve; indeed, Allah is with us.', 'Quran 9:40', 'Quran', ['Anxious', 'Lonely', 'Sad']),
  Quote('Fear not. Indeed, I am with you both; I hear and I see.', 'Quran 20:46', 'Quran', ['Anxious', 'Lonely']),
  Quote('Indeed, Allah is with those who are patient.', 'Quran 2:153', 'Quran', ['Stressed', 'Angry', 'Tired']),
  Quote('Perhaps you dislike something while it is good for you, and perhaps you love something while it is bad for you. Allah knows, and you do not know.', 'Quran 2:216', 'Quran', ['Sad', 'Low', 'Stressed']),
  Quote('Sufficient for us is Allah, and He is the best disposer of affairs.', 'Quran 3:173', 'Quran', ['Anxious', 'Stressed']),
  Quote('Call upon Me; I will respond to you.', 'Quran 40:60', 'Quran', ['Lonely', 'Sad', 'Low']),
  Quote('Those who restrain their anger and pardon people: Allah loves the doers of good.', 'Quran 3:134', 'Quran', ['Angry']),
  Quote('Repel evil with what is better.', 'Quran 41:34', 'Quran', ['Angry']),
  Quote('Indeed, the patient will be given their reward without account.', 'Quran 39:10', 'Quran', ['Stressed', 'Tired', 'Sad']),
  Quote('And He found you lost and guided you.', 'Quran 93:7', 'Quran', ['Low']),
  Quote('There is no deity except You; exalted are You. Indeed, I have been of the wrongdoers.', 'Quran 21:87 (prayer of Prophet Yunus)', 'Quran', ['Low', 'Anxious', 'Sad']),
  Quote('Allah intends ease for you, and does not intend hardship for you.', 'Quran 2:185', 'Quran', ['Stressed', 'Tired', 'Anxious']),
  Quote('Whoever fears Allah, He will make a way out for them and provide for them from where they do not expect.', 'Quran 65:2-3', 'Quran', ['Anxious', 'Stressed', 'Low']),
  Quote('My Lord, expand my chest for me and ease my task for me.', 'Quran 20:25-26', 'Quran', ['Stressed', 'Anxious']),
  Quote('Indeed, Allah is with the patient.', 'Quran 8:46', 'Quran', ['Angry', 'Stressed']),

  // ───────── Faith & Hadith ─────────
  Quote('The strong one is not the one who overpowers others, but the one who controls himself when angry.', 'Hadith, Bukhari & Muslim', 'Faith & Hadith', ['Angry']),
  Quote('Your smile in the face of your brother is charity.', 'Hadith, Tirmidhi', 'Faith & Hadith', ['Happy', 'Lonely']),
  Quote('The best of you are those who are best to their families.', 'Hadith, Tirmidhi', 'Faith & Hadith', ['Happy', 'Grateful']),
  Quote('Make things easy and do not make them difficult; give good news and do not drive people away.', 'Hadith, Bukhari', 'Faith & Hadith', ['Stressed']),
  Quote('None of you truly believes until he loves for his brother what he loves for himself.', 'Hadith, Bukhari & Muslim', 'Faith & Hadith', ['Happy']),
  Quote('How wonderful is the affair of the believer: if good comes, he is grateful; if hardship comes, he is patient. Both are good for him.', 'Hadith, Muslim', 'Faith & Hadith', ['Sad', 'Grateful', 'Low', 'Stressed']),
  Quote('Actions are judged by intentions.', 'Hadith, Bukhari & Muslim', 'Faith & Hadith', []),
  Quote('Whoever is not merciful to others will not be shown mercy.', 'Hadith, Bukhari & Muslim', 'Faith & Hadith', ['Angry']),
  Quote('The most beloved deeds to Allah are those done consistently, even if they are small.', 'Hadith, Bukhari & Muslim', 'Faith & Hadith', ['Tired', 'Stressed']),
  Quote('No fatigue, illness, sorrow, sadness, hurt or distress befalls a believer, even a thorn that pricks him, except that Allah removes some of his sins for it.', 'Hadith, Bukhari & Muslim', 'Faith & Hadith', ['Sad', 'Tired', 'Low']),
  Quote('Whoever believes in Allah and the Last Day, let him speak good or remain silent.', 'Hadith, Bukhari & Muslim', 'Faith & Hadith', ['Angry']),
  Quote('He who does not thank people does not thank Allah.', 'Hadith, Tirmidhi', 'Faith & Hadith', ['Grateful', 'Happy']),

  // ───────── Hope & Patience ─────────
  Quote('Hope is being able to see that there is light despite all of the darkness.', 'Desmond Tutu', 'Hope & Patience', ['Low', 'Sad']),
  Quote('Even the darkest night will end, and the sun will rise.', 'Victor Hugo', 'Hope & Patience', ['Low', 'Sad', 'Anxious']),
  Quote('Although the world is full of suffering, it is full also of the overcoming of it.', 'Helen Keller', 'Hope & Patience', ['Sad', 'Low']),
  Quote('Keep your face to the sunshine and you cannot see a shadow.', 'Helen Keller', 'Hope & Patience', ['Sad', 'Low']),
  Quote('Out of suffering have emerged the strongest souls.', 'Khalil Gibran', 'Hope & Patience', ['Sad', 'Low']),
  Quote('Patience is not simply the ability to wait. It is how we behave while we are waiting.', 'Joyce Meyer', 'Hope & Patience', ['Stressed', 'Angry']),
  Quote('Tough times never last, but tough people do.', 'Robert H. Schuller', 'Hope & Patience', ['Low', 'Sad', 'Tired']),
  Quote('Rock bottom became the solid foundation on which I rebuilt my life.', 'J.K. Rowling', 'Hope & Patience', ['Low']),
  Quote('Peace comes from within. Do not seek it without.', 'Buddha', 'Hope & Patience', ['Anxious', 'Stressed', 'Angry']),
  Quote('You yourself, as much as anybody in the entire universe, deserve your love and affection.', 'Buddha', 'Hope & Patience', ['Low', 'Sad', 'Lonely']),
  Quote('This too shall pass.', 'Persian proverb', 'Hope & Patience', ['Sad', 'Stressed', 'Low', 'Anxious']),
  Quote('The best way out is always through.', 'Robert Frost', 'Hope & Patience', ['Sad', 'Stressed', 'Low']),
  Quote('Holding on to anger is like grasping a hot coal with the intent of throwing it at someone else; you are the one who gets burned.', 'Buddhist teaching', 'Hope & Patience', ['Angry']),

  // ───────── Motivation ─────────
  Quote('The only way to do great work is to love what you do.', 'Steve Jobs', 'Motivation', []),
  Quote('It always seems impossible until it is done.', 'Nelson Mandela', 'Motivation', ['Tired', 'Low']),
  Quote('Do what you can, with what you have, where you are.', 'Theodore Roosevelt', 'Motivation', ['Stressed']),
  Quote('You miss 100% of the shots you don\'t take.', 'Wayne Gretzky', 'Motivation', []),
  Quote('Act as if what you do makes a difference. It does.', 'William James', 'Motivation', []),
  Quote('Believe you can and you\'re halfway there.', 'Theodore Roosevelt', 'Motivation', ['Low']),
  Quote('You may encounter many defeats, but you must not be defeated.', 'Maya Angelou', 'Motivation', ['Low', 'Tired', 'Sad']),
  Quote('It does not matter how slowly you go as long as you do not stop.', 'Confucius', 'Motivation', ['Tired', 'Low']),
  Quote('You must do the thing you think you cannot do.', 'Eleanor Roosevelt', 'Motivation', ['Anxious']),
  Quote('Our greatest weakness lies in giving up. The most certain way to succeed is always to try just one more time.', 'Thomas Edison', 'Motivation', ['Tired', 'Low']),
  Quote('The greatest glory in living lies not in never falling, but in rising every time we fall.', 'Nelson Mandela', 'Motivation', ['Sad', 'Low']),
  Quote('A year from now you may wish you had started today.', 'Karen Lamb', 'Motivation', []),

  // ───────── Success ─────────
  Quote('The best way to predict the future is to create it.', 'Peter Drucker', 'Success', []),
  Quote('Well done is better than well said.', 'Benjamin Franklin', 'Success', []),
  Quote('Success is the sum of small efforts repeated day in and day out.', 'Robert Collier', 'Success', ['Tired']),
  Quote('Whether you think you can or you think you can\'t, you\'re right.', 'Henry Ford', 'Success', []),
  Quote('Quality means doing it right when no one is looking.', 'Henry Ford', 'Success', []),
  Quote('Don\'t watch the clock; do what it does. Keep going.', 'Sam Levenson', 'Success', ['Tired']),
  Quote('Opportunities don\'t happen. You create them.', 'Chris Grosser', 'Success', []),

  // ───────── Wisdom ─────────
  Quote('The journey of a thousand miles begins with a single step.', 'Lao Tzu', 'Wisdom', ['Anxious']),
  Quote('What we think, we become.', 'Buddha', 'Wisdom', []),
  Quote('Knowing is not enough; we must apply.', 'Johann Wolfgang von Goethe', 'Wisdom', []),
  Quote('The unexamined life is not worth living.', 'Socrates', 'Wisdom', []),
  Quote('Simplicity is the ultimate sophistication.', 'Leonardo da Vinci', 'Wisdom', []),
  Quote('He who knows others is wise; he who knows himself is enlightened.', 'Lao Tzu', 'Wisdom', []),
  Quote('Nature does not hurry, yet everything is accomplished.', 'Lao Tzu', 'Wisdom', ['Stressed', 'Tired']),
  Quote('You have power over your mind, not outside events. Realize this, and you will find strength.', 'Marcus Aurelius', 'Wisdom', ['Anxious', 'Stressed', 'Angry']),
  Quote('When we are no longer able to change a situation, we are challenged to change ourselves.', 'Viktor Frankl', 'Wisdom', ['Angry', 'Low']),

  // ───────── Life ─────────
  Quote('Stay hungry, stay foolish.', 'Stewart Brand', 'Life', []),
  Quote('Life is what happens when you\'re busy making other plans.', 'John Lennon', 'Life', []),
  Quote('Everything you can imagine is real.', 'Pablo Picasso', 'Life', []),
  Quote('In the middle of difficulty lies opportunity.', 'Albert Einstein', 'Life', ['Stressed', 'Low']),
  Quote('Happiness is not something ready-made. It comes from your own actions.', 'Dalai Lama', 'Life', ['Happy']),
  Quote('The purpose of our lives is to be happy.', 'Dalai Lama', 'Life', ['Happy']),
  Quote('Life is 10% what happens to us and 90% how we react to it.', 'Charles R. Swindoll', 'Life', ['Angry', 'Stressed']),
  Quote('Breathe. Let go. And remind yourself that this very moment is the only one you know you have for sure.', 'Oprah Winfrey', 'Life', ['Anxious']),

  // ───────── Love & Friendship ─────────
  Quote('Where there is love there is life.', 'Mahatma Gandhi', 'Love & Friendship', ['Lonely', 'Happy']),
  Quote('The best and most beautiful things in the world cannot be seen or even touched. They must be felt with the heart.', 'Helen Keller', 'Love & Friendship', ['Happy', 'Lonely']),
  Quote('A friend is someone who knows all about you and still loves you.', 'Elbert Hubbard', 'Love & Friendship', ['Lonely']),
  Quote('Love all, trust a few, do wrong to none.', 'William Shakespeare', 'Love & Friendship', []),
  Quote('Whoever is happy will make others happy too.', 'Anne Frank', 'Love & Friendship', ['Happy']),
  Quote('Not all of us can do great things. But we can do small things with great love.', 'Mother Teresa', 'Love & Friendship', ['Happy', 'Grateful']),
  Quote('Kindness is a language which the deaf can hear and the blind can see.', 'Mark Twain', 'Love & Friendship', ['Lonely', 'Angry']),
  Quote('No act of kindness, no matter how small, is ever wasted.', 'Aesop', 'Love & Friendship', ['Happy']),

  // ───────── Gratitude ─────────
  Quote('Gratitude is not only the greatest of virtues, but the parent of all others.', 'Cicero', 'Gratitude', ['Grateful']),
  Quote('When I started counting my blessings, my whole life turned around.', 'Willie Nelson', 'Gratitude', ['Grateful', 'Happy']),
  Quote('Enjoy the little things, for one day you may look back and realize they were the big things.', 'Robert Brault', 'Gratitude', ['Grateful', 'Happy']),
  Quote('Silent gratitude isn\'t much use to anyone.', 'G.B. Stern', 'Gratitude', ['Grateful']),
  Quote('Gratitude can transform common days into thanksgivings.', 'William Arthur Ward', 'Gratitude', ['Grateful', 'Happy']),
  Quote('Joy is the simplest form of gratitude.', 'Karl Barth', 'Gratitude', ['Grateful', 'Happy']),

  // ───────── Poetry & Soul ─────────
  Quote('The wound is the place where the Light enters you.', 'Rumi', 'Poetry & Soul', ['Sad', 'Low']),
  Quote('What you seek is seeking you.', 'Rumi', 'Poetry & Soul', ['Low', 'Lonely']),
  Quote('Don\'t grieve. Anything you lose comes round in another form.', 'Rumi', 'Poetry & Soul', ['Sad', 'Low']),
  Quote('Let yourself be silently drawn by the strange pull of what you really love. It will not lead you astray.', 'Rumi', 'Poetry & Soul', ['Anxious']),
  Quote('Yesterday I was clever, so I wanted to change the world. Today I am wise, so I am changing myself.', 'Rumi', 'Poetry & Soul', ['Angry']),
  Quote('Raise yourself so high that before every decree of destiny, God Himself asks you: \u201CWhat is your wish?\u201D', 'Allama Iqbal', 'Poetry & Soul', ['Low', 'Tired']),
  Quote('Beyond the stars there are more worlds still, and more tests of love yet to come.', 'Allama Iqbal', 'Poetry & Soul', ['Low', 'Tired']),
  Quote('Your pain is the breaking of the shell that encloses your understanding.', 'Khalil Gibran', 'Poetry & Soul', ['Sad', 'Low']),
  Quote('Faith is the bird that feels the light and sings while the dawn is still dark.', 'Rabindranath Tagore', 'Poetry & Soul', ['Anxious', 'Low']),
  Quote('You can\'t cross the sea merely by standing and staring at the water.', 'Rabindranath Tagore', 'Poetry & Soul', ['Tired']),
];

// ═══════════════════════════ STATE ═══════════════════════════

class AppState extends ChangeNotifier {
  static const _favKey = 'favorite_quotes';
  static const _themeKey = 'theme_mode';

  Set<String> favorites = {};
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    favorites = (prefs.getStringList(_favKey) ?? []).toSet();
    final saved = prefs.getString(_themeKey);
    if (saved != null) {
      themeMode.value = ThemeMode.values.firstWhere(
        (m) => m.name == saved,
        orElse: () => ThemeMode.system,
      );
    }
    notifyListeners();
  }

  bool isFav(Quote q) => favorites.contains(q.key);

  Future<void> toggleFav(Quote q) async {
    HapticFeedback.lightImpact();
    if (!favorites.remove(q.key)) favorites.add(q.key);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favKey, favorites.toList());
  }

  Future<void> setTheme(ThemeMode m) async {
    themeMode.value = m;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, m.name);
  }
}

final AppState appState = AppState();

// ═══════════════════════════ HELPERS ═══════════════════════════

LinearGradient gradientOf(List<Color> c) => LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: c,
    );

void copyQuote(BuildContext context, Quote q) {
  HapticFeedback.selectionClick();
  Clipboard.setData(ClipboardData(text: '\u201C${q.text}\u201D \u2014 ${q.author}'));
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(const SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 2),
      content: Text('Quote copied to clipboard'),
    ));
}

Quote quoteOfTheDay() {
  final now = DateTime.now();
  final day = DateTime(now.year, now.month, now.day).difference(DateTime(2024)).inDays;
  return allQuotes[Random(day).nextInt(allQuotes.length)];
}

String greeting() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Good morning';
  if (h < 17) return 'Good afternoon';
  return 'Good evening';
}

String dateLabel(DateTime d) {
  const w = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${w[d.weekday - 1]}, ${d.day} ${m[d.month - 1]}';
}

IconData iconForCategory(String name) {
  if (name == 'All') return Icons.auto_awesome;
  return categoryInfos.firstWhere((c) => c.name == name).icon;
}

int countIn(String category) => allQuotes.where((q) => q.category == category).length;

const List<List<Color>> discoverGradients = [
  [Color(0xFF667EEA), Color(0xFF764BA2)],
  [Color(0xFFFF512F), Color(0xFFDD2476)],
  [Color(0xFF11998E), Color(0xFF38EF7D)],
  [Color(0xFF2193B0), Color(0xFF6DD5ED)],
  [Color(0xFFF7971E), Color(0xFFFFB347)],
  [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
];

// ═══════════════════════════ APP ROOT ═══════════════════════════

class QuoteApp extends StatefulWidget {
  const QuoteApp({super.key});

  @override
  State<QuoteApp> createState() => _QuoteAppState();
}

class _QuoteAppState extends State<QuoteApp> {
  @override
  void initState() {
    super.initState();
    appState.load();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appState.themeMode,
      builder: (_, mode, __) => MaterialApp(
        title: 'Daily Quotes',
        debugShowCheckedModeBanner: false,
        themeMode: mode,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF667EEA)),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF667EEA),
          brightness: Brightness.dark,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

// ═══════════════════════════ SPLASH ═══════════════════════════

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) => const HomeShell(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = CurvedAnimation(parent: _c, curve: Curves.elasticOut);
    final fade = CurvedAnimation(parent: _c, curve: const Interval(0.4, 1.0));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: scale,
                child: const Text(
                  '\u201C',
                  style: TextStyle(
                    fontSize: 140,
                    height: 1,
                    color: Colors.white,
                    fontFamily: 'serif',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              FadeTransition(
                opacity: fade,
                child: const Column(
                  children: [
                    Text('Daily Quotes',
                        style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1)),
                    SizedBox(height: 8),
                    Text('Words that lift your heart',
                        style: TextStyle(color: Colors.white70, fontSize: 15)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════ SHELL (responsive navigation) ═══════════════════════════

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  void _go(int i) {
    HapticFeedback.selectionClick();
    setState(() => _tab = i);
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 800;
    final pages = [
      HomePage(onOpenDiscover: () => _go(1)),
      const DiscoverPage(),
      const FavoritesPage(),
    ];

    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final favCount = appState.favorites.length;
        Widget favIcon(bool selected) => Badge(
              isLabelVisible: favCount > 0,
              label: Text('$favCount'),
              child: Icon(selected ? Icons.favorite : Icons.favorite_border),
            );

        if (wide) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _tab,
                  onDestinationSelected: _go,
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    const NavigationRailDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home),
                        label: Text('Home')),
                    const NavigationRailDestination(
                        icon: Icon(Icons.explore_outlined),
                        selectedIcon: Icon(Icons.explore),
                        label: Text('Discover')),
                    NavigationRailDestination(
                        icon: favIcon(false),
                        selectedIcon: favIcon(true),
                        label: const Text('Favorites')),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: IndexedStack(index: _tab, children: pages)),
              ],
            ),
          );
        }

        return Scaffold(
          body: IndexedStack(index: _tab, children: pages),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: _go,
            destinations: [
              const NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home'),
              const NavigationDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore),
                  label: 'Discover'),
              NavigationDestination(
                  icon: favIcon(false), selectedIcon: favIcon(true), label: 'Favorites'),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════ SETTINGS ═══════════════════════════

void showSettings(BuildContext context) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 560),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Appearance', style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 16),
            ValueListenableBuilder<ThemeMode>(
              valueListenable: appState.themeMode,
              builder: (_, mode, __) => SizedBox(
                width: double.infinity,
                child: SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode),
                        label: Text('Light')),
                    ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto),
                        label: Text('Auto')),
                    ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode),
                        label: Text('Dark')),
                  ],
                  selected: {mode},
                  onSelectionChanged: (s) => appState.setTheme(s.first),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Tips', style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text('\u2022 Tap "How are you feeling?" on Home for quotes that fit your mood'),
            const Text('\u2022 In Discover, swipe left or right for another quote'),
            const Text('\u2022 Double-tap a quote to save it, long-press to copy'),
          ],
        ),
      ),
    ),
  );
}

// ═══════════════════════════ HOME PAGE ═══════════════════════════

class HomePage extends StatelessWidget {
  final VoidCallback onOpenDiscover;
  const HomePage({super.key, required this.onOpenDiscover});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(greeting(),
                              style: TextStyle(
                                  color: scheme.onSurfaceVariant, fontSize: 15)),
                          const SizedBox(height: 2),
                          const Text('Find your words today',
                              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      tooltip: 'Settings',
                      onPressed: () => showSettings(context),
                      icon: const Icon(Icons.tune),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Mood card + Quote of the day (side by side on wide screens)
                LayoutBuilder(builder: (context, c) {
                  final mood = _MoodCard(onTap: () => showMoodPicker(context));
                  const daily = _DailyQuoteCard();
                  if (c.maxWidth >= 720) {
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 4, child: mood),
                          const SizedBox(width: 16),
                          const Expanded(flex: 6, child: daily),
                        ],
                      ),
                    );
                  }
                  return Column(children: [mood, const SizedBox(height: 16), daily]);
                }),

                const SizedBox(height: 28),
                Row(
                  children: [
                    const Expanded(
                      child: Text('Explore by category',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    ),
                    TextButton.icon(
                      onPressed: onOpenDiscover,
                      icon: const Icon(Icons.shuffle, size: 18),
                      label: const Text('Random'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categoryInfos.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 240,
                    mainAxisExtent: 140,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                  ),
                  itemBuilder: (_, i) => _CategoryTile(info: categoryInfos[i]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MoodCard extends StatelessWidget {
  final VoidCallback onTap;
  const _MoodCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: gradientOf(const [Color(0xFF4F46E5), Color(0xFFEC4899)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.favorite, color: Colors.white, size: 34),
          const SizedBox(height: 14),
          const Text('How are you feeling today?',
              style: TextStyle(
                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1.2)),
          const SizedBox(height: 8),
          const Text('Tell me, and I\'ll find words that fit your heart.',
              style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.35)),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.emoji_emotions_outlined),
            label: const Text('Tell me how I feel'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              minimumSize: const Size(0, 50),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyQuoteCard extends StatelessWidget {
  const _DailyQuoteCard();

  @override
  Widget build(BuildContext context) {
    final q = quoteOfTheDay();
    final now = DateTime.now();
    final colors = discoverGradients[Random(now.day + now.month).nextInt(discoverGradients.length)];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: gradientOf(colors),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wb_sunny, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text('QUOTE OF THE DAY',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w800)),
              const Spacer(),
              Text(dateLabel(now),
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 18),
          Text('\u201C${q.text}\u201D',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  height: 1.4,
                  fontFamily: 'serif',
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          Text('\u2014 ${q.author}',
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          AnimatedBuilder(
            animation: appState,
            builder: (context, _) {
              final fav = appState.isFav(q);
              return Row(
                children: [
                  _RoundAction(
                    tooltip: fav ? 'Remove from favorites' : 'Add to favorites',
                    icon: fav ? Icons.favorite : Icons.favorite_border,
                    iconColor: fav ? const Color(0xFFFFC2D1) : Colors.white,
                    onPressed: () => appState.toggleFav(q),
                  ),
                  const SizedBox(width: 10),
                  _RoundAction(
                    tooltip: 'Copy quote',
                    icon: Icons.copy,
                    onPressed: () => copyQuote(context, q),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryInfo info;
  const _CategoryTile({required this.info});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: gradientOf(info.colors),
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CategoryScreen(info: info)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(info.icon, color: Colors.white, size: 32),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(info.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            height: 1.15)),
                    const SizedBox(height: 4),
                    Text('${countIn(info.name)} quotes',
                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════ MOOD PICKER + MOOD SCREEN ═══════════════════════════

void showMoodPicker(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 600),
    builder: (ctx) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How are you feeling right now?',
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('Pick one and I\'ll bring you quotes to match.',
                style: TextStyle(color: Theme.of(ctx).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 20),
            LayoutBuilder(builder: (_, c) {
              const gap = 12.0;
              final cols = c.maxWidth >= 480 ? 3 : 2;
              final w = (c.maxWidth - gap * (cols - 1)) / cols;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final m in moods)
                    SizedBox(
                      width: w,
                      height: 76,
                      child: Material(
                        color: Colors.transparent,
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: gradientOf(m.colors),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              Navigator.pop(ctx);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => MoodScreen(mood: m)),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(m.icon, color: Colors.white, size: 26),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(m.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    ),
  );
}

class MoodScreen extends StatefulWidget {
  final Mood mood;
  const MoodScreen({super.key, required this.mood});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  late final List<Quote> _pool;
  int _i = 0;
  int _dir = 1;

  @override
  void initState() {
    super.initState();
    _pool = allQuotes.where((q) => q.moods.contains(widget.mood.name)).toList()..shuffle();
    if (_pool.isEmpty) _pool.addAll(allQuotes);
  }

  void _next() {
    HapticFeedback.selectionClick();
    setState(() {
      _dir = 1;
      _i = (_i + 1) % _pool.length;
    });
  }

  void _prev() {
    HapticFeedback.selectionClick();
    setState(() {
      _dir = -1;
      _i = (_i - 1 + _pool.length) % _pool.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = _pool[_i];
    final mood = widget.mood;
    final wide = MediaQuery.of(context).size.width > 700;

    return Container(
      decoration: BoxDecoration(gradient: gradientOf(mood.colors)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          foregroundColor: Colors.white,
          title: Text('Feeling ${mood.name.toLowerCase()}',
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
                    child: Row(
                      children: [
                        Icon(mood.icon, color: Colors.white, size: 30),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(mood.intro,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16, height: 1.35)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragEnd: (d) {
                        final v = d.primaryVelocity ?? 0;
                        if (v < -250) _next();
                        if (v > 250) _prev();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 420),
                            transitionBuilder: (child, anim) => FadeTransition(
                              opacity: anim,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: Offset(0.12 * _dir, 0),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                    parent: anim, curve: Curves.easeOutCubic)),
                                child: child,
                              ),
                            ),
                            child: QuoteBody(
                              key: ValueKey(q.key),
                              quote: q,
                              fontSize: wide ? 32 : 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (mood.sensitive)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.volunteer_activism, color: Colors.white70, size: 20),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'If these feelings stay heavy for a long time, please talk to someone you trust or a mental health professional. You deserve support.',
                                style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.35),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: AnimatedBuilder(
                      animation: appState,
                      builder: (context, _) {
                        final fav = appState.isFav(q);
                        return Row(
                          children: [
                            _RoundAction(
                              tooltip: 'Previous',
                              icon: Icons.arrow_back,
                              onPressed: _prev,
                            ),
                            const SizedBox(width: 10),
                            _RoundAction(
                              tooltip: fav ? 'Remove from favorites' : 'Add to favorites',
                              icon: fav ? Icons.favorite : Icons.favorite_border,
                              iconColor: fav ? const Color(0xFFFFC2D1) : Colors.white,
                              onPressed: () => appState.toggleFav(q),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _next,
                                icon: const Icon(Icons.auto_awesome),
                                label: const Text('Another one',
                                    style: TextStyle(fontWeight: FontWeight.w700)),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black87,
                                  minimumSize: const Size.fromHeight(54),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            _RoundAction(
                              tooltip: 'Copy quote',
                              icon: Icons.copy,
                              onPressed: () => copyQuote(context, q),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════ CATEGORY SCREEN ═══════════════════════════

class CategoryScreen extends StatelessWidget {
  final CategoryInfo info;
  const CategoryScreen({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final quotes = allQuotes.where((q) => q.category == info.name).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(info.icon, size: 22),
            const SizedBox(width: 10),
            Flexible(child: Text(info.name, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: LayoutBuilder(builder: (context, c) {
            const pad = 16.0;
            const gap = 14.0;
            final cols = c.maxWidth >= 760 ? 2 : 1;
            final itemW = (c.maxWidth - pad * 2 - gap * (cols - 1)) / cols;

            return ListView(
              padding: const EdgeInsets.all(pad),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: gradientOf(info.colors),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(info.icon, color: Colors.white, size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(info.blurb,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(
                              info.name == 'Quran'
                                  ? '${quotes.length} verses \u2022 shown as simple English renderings of their meanings'
                                  : '${quotes.length} quotes',
                              style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final q in quotes)
                      SizedBox(width: itemW, child: QuoteCard(quote: q)),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

// ═══════════════════════════ DISCOVER (random + swipe) ═══════════════════════════

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final Random _random = Random();
  String _category = 'All';
  late Quote _current;
  int _gradientIndex = 0;
  int _direction = 1;
  final List<Quote> _history = [];
  bool _burst = false;

  List<String> get _chips => ['All', ...categoryInfos.map((c) => c.name)];

  List<Quote> get _pool =>
      _category == 'All' ? allQuotes : allQuotes.where((q) => q.category == _category).toList();

  @override
  void initState() {
    super.initState();
    _current = allQuotes[_random.nextInt(allQuotes.length)];
    _gradientIndex = _random.nextInt(discoverGradients.length);
  }

  void _newQuote() {
    HapticFeedback.selectionClick();
    final pool = _pool;
    Quote next;
    do {
      next = pool[_random.nextInt(pool.length)];
    } while (pool.length > 1 && next.key == _current.key);
    setState(() {
      _history.add(_current);
      if (_history.length > 20) _history.removeAt(0);
      _direction = 1;
      _current = next;
      _gradientIndex = (_gradientIndex + 1) % discoverGradients.length;
    });
  }

  void _previous() {
    if (_history.isEmpty) {
      HapticFeedback.heavyImpact();
      return;
    }
    HapticFeedback.selectionClick();
    setState(() {
      _direction = -1;
      _current = _history.removeLast();
      _gradientIndex =
          (_gradientIndex - 1 + discoverGradients.length) % discoverGradients.length;
    });
  }

  void _select(String c) {
    if (c == _category) return;
    HapticFeedback.selectionClick();
    setState(() {
      _category = c;
      _history.clear();
    });
    _newQuote();
  }

  Future<void> _doubleTap() async {
    if (!appState.isFav(_current)) appState.toggleFav(_current);
    setState(() => _burst = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) setState(() => _burst = false);
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 700;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 700),
      decoration: BoxDecoration(gradient: gradientOf(discoverGradients[_gradientIndex])),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          foregroundColor: Colors.white,
          title: const Text('Discover',
              style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          actions: [
            IconButton(
              tooltip: 'Settings',
              onPressed: () => showSettings(context),
              icon: const Icon(Icons.tune),
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                children: [
                  SizedBox(
                    height: 52,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      itemCount: _chips.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final c = _chips[i];
                        final selected = c == _category;
                        return ChoiceChip(
                          avatar: Icon(iconForCategory(c),
                              size: 18, color: selected ? Colors.black87 : Colors.white),
                          label: Text(c),
                          selected: selected,
                          showCheckmark: false,
                          onSelected: (_) => _select(c),
                          selectedColor: Colors.white,
                          backgroundColor: Colors.white24,
                          side: BorderSide.none,
                          labelStyle: TextStyle(
                            color: selected ? Colors.black87 : Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragEnd: (d) {
                        final v = d.primaryVelocity ?? 0;
                        if (v < -250) _newQuote();
                        if (v > 250) _previous();
                      },
                      onDoubleTap: _doubleTap,
                      onLongPress: () => copyQuote(context, _current),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 420),
                              transitionBuilder: (child, anim) {
                                final slide = Tween<Offset>(
                                  begin: Offset(0.15 * _direction, 0),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                    parent: anim, curve: Curves.easeOutCubic));
                                return FadeTransition(
                                  opacity: anim,
                                  child: SlideTransition(position: slide, child: child),
                                );
                              },
                              child: QuoteBody(
                                key: ValueKey(_current.key),
                                quote: _current,
                                fontSize: wide ? 34 : 26,
                              ),
                            ),
                          ),
                          IgnorePointer(
                            child: AnimatedScale(
                              scale: _burst ? 1.0 : 0.3,
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.elasticOut,
                              child: AnimatedOpacity(
                                opacity: _burst ? 1 : 0,
                                duration: const Duration(milliseconds: 250),
                                child: const Icon(Icons.favorite, size: 120, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: AnimatedBuilder(
                      animation: appState,
                      builder: (context, _) {
                        final isFav = appState.isFav(_current);
                        return Row(
                          children: [
                            _RoundAction(
                              tooltip: 'Previous quote',
                              icon: Icons.arrow_back,
                              onPressed: _history.isEmpty ? null : _previous,
                            ),
                            const SizedBox(width: 10),
                            _RoundAction(
                              tooltip: isFav ? 'Remove from favorites' : 'Add to favorites',
                              icon: isFav ? Icons.favorite : Icons.favorite_border,
                              iconColor: isFav ? const Color(0xFFFFC2D1) : Colors.white,
                              onPressed: () => appState.toggleFav(_current),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _newQuote,
                                icon: const Icon(Icons.refresh),
                                label: const Text('New Quote',
                                    style: TextStyle(fontWeight: FontWeight.w700)),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black87,
                                  minimumSize: const Size.fromHeight(54),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            _RoundAction(
                              tooltip: 'Copy quote',
                              icon: Icons.copy,
                              onPressed: () => copyQuote(context, _current),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════ FAVORITES ═══════════════════════════

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
              tooltip: 'Settings',
              onPressed: () => showSettings(context),
              icon: const Icon(Icons.tune)),
        ],
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          final quotes = allQuotes.where(appState.isFav).toList();

          if (quotes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite_border, size: 72, color: scheme.outline),
                    const SizedBox(height: 16),
                    Text('No favorites yet', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the heart on any quote to keep it here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: LayoutBuilder(builder: (context, c) {
                const pad = 16.0;
                const gap = 14.0;
                final cols = c.maxWidth >= 760 ? 2 : 1;
                final itemW = (c.maxWidth - pad * 2 - gap * (cols - 1)) / cols;
                return ListView(
                  padding: const EdgeInsets.all(pad),
                  children: [
                    Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        for (final q in quotes)
                          SizedBox(width: itemW, child: QuoteCard(quote: q)),
                      ],
                    ),
                  ],
                );
              }),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════ SHARED WIDGETS ═══════════════════════════

/// Big white-on-gradient quote used on Discover and Mood screens.
class QuoteBody extends StatelessWidget {
  final Quote quote;
  final double fontSize;
  const QuoteBody({super.key, required this.quote, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${quote.text} by ${quote.author}',
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('\u201C',
                style: TextStyle(
                  fontSize: 80,
                  height: 0.8,
                  color: Colors.white54,
                  fontFamily: 'serif',
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 8),
            Text(
              quote.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontFamily: 'serif',
                height: 1.45,
                fontWeight: FontWeight.w600,
                shadows: const [Shadow(blurRadius: 12, color: Colors.black26)],
              ),
            ),
            const SizedBox(height: 24),
            Container(width: 48, height: 3, color: Colors.white54),
            const SizedBox(height: 14),
            Text(
              quote.author.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                letterSpacing: 2,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(quote.category,
                  style: const TextStyle(color: Colors.white, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card used in category and favorites lists.
class QuoteCard extends StatelessWidget {
  final Quote quote;
  const QuoteCard({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer.withAlpha(90),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (quote.isQuran)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(Icons.menu_book, size: 16, color: scheme.primary),
                  const SizedBox(width: 6),
                  Text('QURAN',
                      style: TextStyle(
                          color: scheme.primary,
                          fontSize: 11.5,
                          letterSpacing: 1.6,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          Text(
            '\u201C${quote.text}\u201D',
            style: const TextStyle(
                fontSize: 18, height: 1.45, fontFamily: 'serif', fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text('\u2014 ${quote.author}',
                    style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w700)),
              ),
              AnimatedBuilder(
                animation: appState,
                builder: (context, _) {
                  final fav = appState.isFav(quote);
                  return IconButton(
                    tooltip: fav ? 'Remove from favorites' : 'Add to favorites',
                    icon: Icon(fav ? Icons.favorite : Icons.favorite_border, size: 22),
                    color: fav ? Colors.redAccent : null,
                    onPressed: () => appState.toggleFav(quote),
                  );
                },
              ),
              IconButton(
                tooltip: 'Copy',
                icon: const Icon(Icons.copy, size: 20),
                onPressed: () => copyQuote(context, quote),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color iconColor;
  const _RoundAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, color: onPressed == null ? Colors.white38 : iconColor),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white24,
        minimumSize: const Size(54, 54),
      ),
    );
  }
}