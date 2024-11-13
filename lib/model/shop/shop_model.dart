class Shop {
  final String id;
  final String name;
  final String city;
  final String address;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final String workingHours;
  final String phone;
  final String email;
  final List<Review> reviews;

  Shop({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    required this.images,
    required this.rating,
    required this.reviewCount,
    required this.workingHours,
    required this.phone,
    required this.email,
    required this.reviews,
  });
}

class Review {
  final String userId;
  final String userName;
  final String comment;
  final double rating;
  final DateTime date;

  Review({
    required this.userId,
    required this.userName,
    required this.comment,
    required this.rating,
    required this.date,
  });
}
