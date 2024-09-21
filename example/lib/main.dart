import 'package:example/color_wheel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:okcolor/models/extensions.dart';
import 'package:okcolor/models/okcolor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OkColor Demo',
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme().copyWith(),
        sliderTheme: const SliderThemeData(
          activeTrackColor: Colors.black,
          inactiveTrackColor: Colors.black12,
          thumbColor: Colors.black,
          trackHeight: 5,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.all(Colors.black),
          trackColor: WidgetStateProperty.all(Colors.black12),
        ),
      ),
      home: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.gradient), label: 'Gradient'),
            BottomNavigationBarItem(icon: Icon(Icons.color_lens), label: 'Harmonies'),
          ],
          onTap: (value) {
            setState(() {
              index = value;
            });
          },
        ),
        body: [
          const Gradient(),
          const Harmonies(),
        ][index],
      ),
    );
  }
}

class Harmonies extends StatefulWidget {
  const Harmonies({super.key});

  @override
  State<Harmonies> createState() => _HarmoniesState();
}

class _HarmoniesState extends State<Harmonies> {
  Color color = const Color(0xff0000ff);

  double darker = 0;
  double lighter = 0;
  double saturated = 0;
  double desaturated = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Color harmonies'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black12, width: 1),
                  color: color,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return ColorPicker(
                              pickerColor: color,
                              onColorChanged: (color) {
                                setState(() {
                                  this.color = color;
                                });
                              },
                            );
                          },
                        );
                      },
                      child: const SizedBox(
                        height: 120,
                        width: double.infinity,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text("Lightness", style: GoogleFonts.rubik(fontSize: 18, fontWeight: FontWeight.w500, letterSpacing: -0.25)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: color.darker(darker),
                            ),
                            width: double.infinity,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Darker', style: GoogleFonts.rubik(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: -0.25)),
                        const SizedBox(height: 8),
                        Slider(
                          value: darker,
                          onChanged: (value) {
                            setState(() {
                              darker = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: color.lighter(lighter),
                            ),
                            width: double.infinity,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Lighter', style: GoogleFonts.rubik(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: -0.25)),
                        const SizedBox(height: 8),
                        Slider(
                          value: lighter,
                          onChanged: (value) {
                            setState(() {
                              lighter = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Gradient extends StatefulWidget {
  const Gradient({super.key});

  @override
  State<Gradient> createState() => _GradientState();
}

class _GradientState extends State<Gradient> {
  Color startColor = const Color(0xffffffff);
  Color endColor = const Color(0xff0000ff);
  int numberOfColors = 20;
  bool shortest = true;

  Widget _buildControls() {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'Number of colors',
              style: GoogleFonts.rubik(fontSize: 18, fontWeight: FontWeight.w500, letterSpacing: -0.25),
            ),
            Expanded(
              child: Slider(
                value: numberOfColors.toDouble(),
                min: 5,
                max: 30,
                divisions: 25,
                label: numberOfColors.toString(),
                onChanged: (value) {
                  setState(() {
                    numberOfColors = value.toInt();
                  });
                },
                activeColor: Colors.black,
                inactiveColor: Colors.black12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGradient(String title, List<Color> colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.rubik(fontSize: 18, fontWeight: FontWeight.w500, letterSpacing: -0.25),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: Durations.short4,
          width: double.infinity,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black12, width: 1),
            gradient: LinearGradient(
              colors: colors,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorWheel() {
    return Column(
      children: [
        Text(
          'Color Wheel',
          style: GoogleFonts.rubik(fontSize: 18, fontWeight: FontWeight.w500, letterSpacing: -0.25),
        ),
        AspectRatio(
          aspectRatio: 1,
          child: Transform.flip(
            flipY: true,
            child: HSVColorWheel(
              gradientColors: OkColor.gradient(startColor, endColor, numberOfColors: numberOfColors, method: InterpolationMethod.oklch),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Gradient',
                style: GoogleFonts.rubik(fontSize: 24, fontWeight: FontWeight.w500, letterSpacing: -0.25),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildColorPicker(context, startColor, 'Start Color', (color) {
                      setState(() {
                        startColor = color;
                      });
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildColorPicker(context, endColor, 'End Color', (color) {
                      setState(() {
                        endColor = color;
                      });
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildColorWheel(),
              const SizedBox(height: 8),
              _buildControls(),
              const SizedBox(height: 8),
              _buildGradient('RGB', OkColor.gradient(startColor, endColor, numberOfColors: numberOfColors, method: InterpolationMethod.rgb)),
              const SizedBox(height: 8),
              _buildGradient('HSV', OkColor.gradient(startColor, endColor, numberOfColors: numberOfColors, method: InterpolationMethod.hsv)),
              const SizedBox(height: 8),
              _buildGradient('OkLab', OkColor.gradient(startColor, endColor, numberOfColors: numberOfColors, method: InterpolationMethod.oklab)),
              const SizedBox(height: 8),
              _buildGradient('OkHsv', OkColor.gradient(startColor, endColor, numberOfColors: numberOfColors, method: InterpolationMethod.okhsv)),
              const SizedBox(height: 8),
              _buildGradient('OkLch', OkColor.gradient(startColor, endColor, numberOfColors: numberOfColors, method: InterpolationMethod.oklch)),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildColorPicker(BuildContext context, Color color, String label, Function(Color) onColorChanged) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black12, width: 1),
          color: color,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return ColorPicker(
                      pickerColor: color,
                      onColorChanged: onColorChanged,
                    );
                  },
                );
              },
              child: const AspectRatio(
                aspectRatio: 1,
                child: SizedBox(
                  width: double.infinity,
                ),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Text(
        label,
        style: GoogleFonts.rubik(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: -0.25),
      ),
    ],
  );
}
