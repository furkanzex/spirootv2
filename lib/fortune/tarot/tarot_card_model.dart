class TarotCard {
  final String id;
  final String name;
  final String image;
  final String meaning;
  bool isSelected;
  bool isRevealed;

  TarotCard({
    required this.id,
    required this.name,
    required this.image,
    required this.meaning,
    this.isSelected = false,
    this.isRevealed = false,
  });

  static List<TarotCard> getDeck() {
    return [
      TarotCard(
        id: '1',
        name: 'Asalar Ası',
        image: 'https://apptoic.com/spiroot/tarot/wands_ace.jpg',
        meaning: 'Yeni başlangıçlar, yaratıcılık ve fırsatlar',
      ),
      TarotCard(
        id: '2',
        name: 'Kılıçlar Ası',
        image: 'https://apptoic.com/spiroot/tarot/swords_ace.jpg',
        meaning: 'Zihinsel netlik, yeni fikirler',
      ),
      TarotCard(
        id: '3',
        name: 'Kupalar Ası',
        image: 'https://apptoic.com/spiroot/tarot/cups_ace.jpg',
        meaning: 'Duygusal yeni başlangıçlar, sevgi',
      ),
      // Daha fazla kart eklenebilir
    ];
  }
}
