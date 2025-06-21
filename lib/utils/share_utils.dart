import 'package:share_plus/share_plus.dart';

class ShareUtil {
  static void shareScore(int score) {
    Share.share("I scored $score in the Wordle Flutter Game!");
  }


}
