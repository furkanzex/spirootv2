class TarotCard {
  final String name;
  final String number;
  final String arcana;
  final String suit;
  final String image;
  final List<String> fortuneTelling;
  final List<String> keywords;
  final Map<String, List<String>> meanings;
  final String archetype;
  final String hebrewAlphabet;
  final String numerology;
  final String elemental;
  final String mythicalSpiritual;
  final List<String> questionsToAsk;
  bool isSelected;
  bool isRevealed;

  TarotCard({
    required this.name,
    required this.number,
    required this.arcana,
    required this.suit,
    required this.image,
    required this.fortuneTelling,
    required this.keywords,
    required this.meanings,
    required this.archetype,
    required this.hebrewAlphabet,
    required this.numerology,
    required this.elemental,
    required this.mythicalSpiritual,
    required this.questionsToAsk,
    this.isSelected = false,
    this.isRevealed = false,
  });

  factory TarotCard.fromJson(Map<String, dynamic> json) {
    return TarotCard(
      name: json['name'] ?? '',
      number: json['number']?.toString() ?? '',
      arcana: json['arcana'] ?? '',
      suit: json['suit'] ?? '',
      image: 'assets/images/tarot/${json['img']}',
      fortuneTelling: List<String>.from(json['fortune_telling'] ?? []),
      keywords: List<String>.from(json['keywords'] ?? []),
      meanings: {
        'light': List<String>.from(json['meanings']?['light'] ?? []),
        'shadow': List<String>.from(json['meanings']?['shadow'] ?? []),
      },
      archetype: json['arche_type'] ?? '',
      hebrewAlphabet: json['hebrew_alphabet'] ?? '',
      numerology: json['numerology'] ?? '',
      elemental: json['elemental'] ?? '',
      mythicalSpiritual: json['mythical_spiritual'] ?? '',
      questionsToAsk: List<String>.from(json['questions_to_ask'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'number': number,
      'arcana': arcana,
      'suit': suit,
      'image': image,
      'fortune_telling': fortuneTelling,
      'keywords': keywords,
      'meanings': meanings,
      'arche_type': archetype,
      'hebrew_alphabet': hebrewAlphabet,
      'numerology': numerology,
      'elemental': elemental,
      'mythical_spiritual': mythicalSpiritual,
      'questions_to_ask': questionsToAsk,
      'isSelected': isSelected,
      'isRevealed': isRevealed,
    };
  }

  String get meaning => fortuneTelling.join('. ');
}
