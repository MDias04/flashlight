import 'package:flutter/material.dart';
import 'package:torch_light/torch_light.dart';

class Flashlight extends StatefulWidget {
  const Flashlight({super.key});

  @override
  State<Flashlight> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Flashlight> with WidgetsBindingObserver {
  bool isOn = false;

  @override
  void initState() {
    super.initState();
    // Register this object as a binding observer
    WidgetsBinding.instance.addObserver(this);
    _checkTorchAvailability();
  }

  @override
  void dispose() {
    // Unregister this object as a binding observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // This method is called whenever the app lifecycle state changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('AppLifecycleState changed to: $state');

    if (state == AppLifecycleState.inactive) {
      // Keep the flashlight on when the app is inactive (e.g., when user is switching apps)
      if (isOn) {
        print('App is inactive. Keeping flashlight on.');
      }
    } else if (state == AppLifecycleState.paused) {
      // Turn off the flashlight if the app is paused (e.g., user minimizes the app)
      if (isOn) {
        _turnFlashlightOn();
        print('App is paused. Keeping flashlight on.');
      }
    } else if (state == AppLifecycleState.resumed) {
      // Turn on the flashlight if it was on before the app was paused or inactive
      if (isOn) {
        _turnFlashlightOn();
        print('App is resumed. Turning flashlight on.');
      }
    } else if (state == AppLifecycleState.detached) {
      // Ensure the flashlight is off when the app is detached (closed)
      if (isOn) {
        _turnFlashlightOff();
        print('App is detached. Turning flashlight off.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () async {
                if (await _isTorchAvailable()) {
                  setState(() {
                    isOn = !isOn;
                    if (isOn) {
                      _turnFlashlightOn();
                    } else {
                      _turnFlashlightOff();
                    }
                  });
                }
              },
              child: Stack(
                children: [
                  isOn ? const Icon(Icons.flashlight_on, size: 300) : const Icon(Icons.flashlight_off, size: 300),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkTorchAvailability() async {
    bool available = await _isTorchAvailable();
    if (!available && mounted) {
      _showMessage('Torch not available on this device');
    }
  }

  Future<bool> _isTorchAvailable() async {
    try {
      return await TorchLight.isTorchAvailable();
    } on Exception catch (_) {
      if (mounted) {
        _showMessage('Could not check if the device has an available torch');
      }
      return false;
    }
  }

  Future<void> _turnFlashlightOn() async {
    try {
      await TorchLight.enableTorch();
    } on Exception catch (_) {
      if (mounted) {
        _showMessage('Could not enable torch');
      }
    }
  }

  Future<void> _turnFlashlightOff() async {
    try {
      await TorchLight.disableTorch();
    } on Exception catch (_) {
      if (mounted) {
        _showMessage('Could not disable torch');
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
