import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../bluetooth/blender.dart';
import '../bluetooth/connection_state.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();

    BLEnder.subscribeImu();

    ConnectionStateService.imuAngle.addListener(_onImuChanged);
  }

  void _onImuChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    ConnectionStateService.imuAngle.removeListener(_onImuChanged);
    BLEnder.stopImu();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final angle =
        ConnectionStateService.imuAngle.value / 100.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'IMU Angle: ${angle.toStringAsFixed(2)}°',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30
          ),
        ),
      ),
    );
  }
} 