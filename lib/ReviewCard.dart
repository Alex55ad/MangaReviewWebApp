import 'package:flutter/material.dart';

class ReviewCard extends StatelessWidget {
  final String username;
  final String mangaTitle;
  final int chapter;
  final String reviewTitle;
  final String reviewBody;
  final String coverUrl;
  final String date;
  final bool isDarkMode; // New parameter to determine the theme

  const ReviewCard({
    Key? key,
    required this.username,
    required this.mangaTitle,
    required this.chapter,
    required this.reviewTitle,
    required this.reviewBody,
    required this.coverUrl,
    required this.date,
    required this.isDarkMode, // Initialize new parameter
  }) : super(key: key);

  String formatRelativeDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays >= 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays >= 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} hours ago';
    } else {
      return 'Just now'; // For less than an hour
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Parse the date string into a DateTime object
    final reviewDate = DateTime.parse(date);
    final formattedDate = formatRelativeDate(reviewDate);

    final cardColor = isDarkMode ? Colors.black : Colors.white;

    return Container(
      color: cardColor,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // Manga cover image
          Image.network(
            coverUrl,
            fit: BoxFit.contain,
            width: 50,
            height: 50,
          ),
          SizedBox(width: 10),
          // Review content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top line with username, manga title, and date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: username,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          TextSpan(
                            text: ' read chapter $chapter of ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: mangaTitle,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                // Review title
                Text(
                  reviewTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                // Review body
                Text(
                  reviewBody,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
