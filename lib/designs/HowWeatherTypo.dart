import 'package:client/designs/howWeatherColor.dart';
import 'package:flutter/material.dart';

class Bold_64px extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final TextOverflow? overflow;

  const Bold_64px({
    Key? key,
    required this.text,
    this.color,
    this.overflow,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
          color: color ?? HowWeatherColor.neutral[900],
          fontFamily: 'Pretendard',
          fontSize: 64,
          fontWeight: FontWeight.w700),
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

class Bold_40px extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final TextOverflow? overflow;

  const Bold_40px({
    Key? key,
    required this.text,
    this.color,
    this.overflow,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
          color: color ?? HowWeatherColor.neutral[900],
          fontFamily: 'Pretendard',
          fontSize: 40,
          fontWeight: FontWeight.w700),
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

class Bold_32px extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final TextOverflow? overflow;

  const Bold_32px({
    Key? key,
    required this.text,
    this.color,
    this.overflow,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
          color: color ?? HowWeatherColor.neutral[900],
          fontFamily: 'Pretendard',
          fontSize: 32,
          fontWeight: FontWeight.w700),
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

class Bold_26px extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final TextOverflow? overflow;

  const Bold_26px({
    Key? key,
    required this.text,
    this.color,
    this.overflow,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
          color: color ?? HowWeatherColor.neutral[900],
          fontFamily: 'Pretendard',
          fontSize: 26,
          fontWeight: FontWeight.w700),
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

class Bold_24px extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final TextOverflow? overflow;

  const Bold_24px({
    Key? key,
    required this.text,
    this.color,
    this.overflow,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
          color: color ?? HowWeatherColor.neutral[900],
          fontFamily: 'Pretendard',
          fontSize: 24,
          fontWeight: FontWeight.w700),
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

class Bold_22px extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final TextOverflow? overflow;

  const Bold_22px({
    Key? key,
    required this.text,
    this.color,
    this.overflow,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
          color: color ?? HowWeatherColor.neutral[900],
          fontFamily: 'Pretendard',
          fontSize: 22,
          fontWeight: FontWeight.w700),
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

class Bold_20px extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final TextOverflow? overflow;

  const Bold_20px({
    Key? key,
    required this.text,
    this.color,
    this.overflow,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
          color: color ?? HowWeatherColor.neutral[900],
          fontFamily: 'Pretendard',
          fontSize: 20,
          fontWeight: FontWeight.w700),
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

// pretendard semibold

class Semibold_28px extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final TextOverflow? overflow;

  const Semibold_28px({
    Key? key,
    required this.text,
    this.color,
    this.overflow,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
          color: color ?? HowWeatherColor.neutral[900],
          fontFamily: 'Pretendard',
          fontSize: 28,
          fontWeight: FontWeight.w600),
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

class Semibold_24px extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final TextOverflow? overflow;

  const Semibold_24px({
    Key? key,
    required this.text,
    this.color,
    this.overflow,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
          color: color ?? HowWeatherColor.neutral[900],
          fontFamily: 'Pretendard',
          fontSize: 24,
          fontWeight: FontWeight.w600),
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

class Semibold_22px extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  const Semibold_22px({
    Key? key,
    required this.text,
    this.color,
    this.overflow,
    this.textAlign,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign ?? TextAlign.start,
      style: style.copyWith(
        color: color ?? HowWeatherColor.neutral[900],
        fontFamily: 'Pretendard',
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

class Semibold_20px extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final TextOverflow? overflow;

  const Semibold_20px({
    Key? key,
    required this.text,
    this.color,
    this.overflow,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
          color: color ?? HowWeatherColor.neutral[900],
          fontFamily: 'Pretendard',
          fontSize: 20,
          fontWeight: FontWeight.w600),
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

class Semibold_18px extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final TextOverflow? overflow;

  const Semibold_18px({
    Key? key,
    required this.text,
    this.color,
    this.overflow,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
          color: color ?? HowWeatherColor.neutral[900],
          fontFamily: 'Pretendard',
          fontSize: 18,
          fontWeight: FontWeight.w600),
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

class Semibold_16px extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final TextOverflow? overflow;

  const Semibold_16px({
    Key? key,
    required this.text,
    this.color,
    this.overflow,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
          color: color ?? HowWeatherColor.neutral[900],
          fontFamily: 'Pretendard',
          fontSize: 16,
          fontWeight: FontWeight.w600),
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

// pretendard medium

class Medium_20px extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final TextOverflow? overflow;

  const Medium_20px({
    Key? key,
    required this.text,
    this.color,
    this.overflow,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
          color: color ?? HowWeatherColor.neutral[900],
          fontFamily: 'Pretendard',
          fontSize: 20,
          fontWeight: FontWeight.w500),
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

class Medium_18px extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final TextOverflow? overflow;

  const Medium_18px({
    Key? key,
    required this.text,
    this.color,
    this.overflow,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
          color: color ?? HowWeatherColor.neutral[900],
          fontFamily: 'Pretendard',
          fontSize: 18,
          fontWeight: FontWeight.w500),
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

class Medium_16px extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final TextOverflow? overflow;

  const Medium_16px({
    Key? key,
    required this.text,
    this.color,
    this.overflow,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
          color: color ?? HowWeatherColor.neutral[900],
          fontFamily: 'Pretendard',
          fontSize: 16,
          fontWeight: FontWeight.w500),
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

class Medium_14px extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final TextOverflow? overflow;

  const Medium_14px({
    Key? key,
    required this.text,
    this.color,
    this.overflow,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
          color: color ?? HowWeatherColor.neutral[900],
          fontFamily: 'Pretendard',
          fontSize: 14,
          fontWeight: FontWeight.w500),
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}
