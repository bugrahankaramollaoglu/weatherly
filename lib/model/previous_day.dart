import 'package:flutter/cupertino.dart';

class NextDay {
  final String nextDay;
  final String imageUrl;
  final int celc;

  NextDay({
    required this.nextDay,
    required this.imageUrl,
    required this.celc,
  });
}

class NextDayWidget extends StatelessWidget {
  final NextDay nDay;

  const NextDayWidget({super.key, required this.nDay});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(nDay.nextDay),
        SizedBox(height: 6),
        Image.network(nDay.imageUrl, width: 50, height: 50),
        SizedBox(height: 6),
        Text('${nDay.celc}°', style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
