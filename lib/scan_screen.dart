import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maizedetect/upload_image.dart';

import 'insights_screen.dart';
import 'maize_theme.dart';
import 'widgets/maize_app_bar.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  CameraController? _controller;

  bool _isInitializing = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isFlashOn = false;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (!mounted) return;

      if (cameras.isEmpty) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Tidak ada kamera yang ditemukan';
          _isInitializing = false;
        });
        return;
      }

      await _setupCamera(cameras.first);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = 'Gagal menginisialisasi kamera: $e';
        _isInitializing = false;
      });
    }
  }

  Future<void> _setupCamera(CameraDescription description) async {
    final controller = CameraController(
      description,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    _controller = controller;

    try {
      await controller.initialize();
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _hasError = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = 'Gagal memulai kamera: $e';
        _isInitializing = false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _controller?.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed && mounted) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  Future<void> _onCapture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _isCapturing) {
      return;
    }

    setState(() => _isCapturing = true);

    try {
      if (_isFlashOn) {
        await controller.setFlashMode(FlashMode.off);
      }

      print('[_onCapture] mulai takePicture');
      final XFile photo = await controller.takePicture();
      print('[_onCapture] foto selesai: ${photo.path}');

      await controller.pausePreview();
      print('[_onCapture] preview paused');

      print('[_onCapture] mulai uploadImage');
      final result = await uploadImage(photo.path);
      print('[_onCapture] uploadImage selesai');

      if (!mounted) return;

      print('[_onCapture] mulai navigate');
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => InsightsScreen(imagePath: photo.path, result: result),
        ),
      );
    } catch (e, st) {
      print('[_onCapture] error: $e');
      print(st);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil atau mengunggah gambar: $e')),
      );
    } finally {
      if (mounted && _controller != null && _controller!.value.isInitialized) {
        try {
          await _controller!.resumePreview();
        } catch (_) {}
      }

      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  Future<void> _onPickGallery() async {
    try {
      final picker = ImagePicker();

      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (image == null) return;

      final result = await uploadImage(image.path);

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => InsightsScreen(imagePath: image.path, result: result),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih atau mengunggah gambar: $e')),
      );
    }
  }

  Future<void> _toggleFlash() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final newFlash = _isFlashOn ? FlashMode.off : FlashMode.torch;
    try {
      await controller.setFlashMode(newFlash);
      setState(() => _isFlashOn = !_isFlashOn);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const MaizeAppBar(),
            Expanded(
              child: Stack(
                children: [
                  // Camera preview or fallback
                  Positioned.fill(child: _buildCameraBackground()),

                  // Overlay UI
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Posisikan daun jagung pada area tengah bingkai untuk pemindaian',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: MaizeColors.inverseOnSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const _GuideFrame(),
                        ],
                      ),
                    ),
                  ),

                  // Bottom controls
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(24, 18, 24, 50),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.78),
                            Colors.black.withValues(alpha: 0),
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _SmallRoundButton(
                            icon: Icons.photo_library_outlined,
                            onPressed: _onPickGallery,
                          ),
                          _ShutterButton(
                            isCapturing: _isCapturing,
                            onPressed: _hasError || _isInitializing
                                ? null
                                : _onCapture,
                          ),
                          _SmallRoundButton(
                            icon: _isFlashOn ? Icons.flash_on : Icons.flash_off,
                            onPressed: _toggleFlash,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Initializing overlay
                  if (_isInitializing)
                    Positioned.fill(
                      child: ColoredBox(
                        color: Colors.black.withValues(alpha: 0.7),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraBackground() {
    if (_hasError) {
      return DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF234A3A), Color(0xFF102A21)],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white54,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isInitializing = true;
                      _hasError = false;
                    });
                    _initCamera();
                  },
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      return SizedBox.expand(
        child: CameraPreview(controller),
      );
    }

    // Fallback background while loading
    return const DecoratedBox(decoration: BoxDecoration(color: Colors.black));
  }
}

class _GuideFrame extends StatelessWidget {
  const _GuideFrame();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: MaizeColors.tertiaryFixed.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: const Stack(
        children: [
          _Corner(Alignment.topLeft),
          _Corner(Alignment.topRight),
          _Corner(Alignment.bottomLeft),
          _Corner(Alignment.bottomRight),
          Align(child: _ScanLine()),
        ],
      ),
    );
  }
}

class _ScanLine extends StatelessWidget {
  const _ScanLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: MaizeColors.tertiaryFixed,
        boxShadow: [
          BoxShadow(
            color: MaizeColors.tertiaryFixed.withValues(alpha: 0.7),
            blurRadius: 12,
          ),
        ],
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  const _Corner(this.alignment);

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final top =
        alignment == Alignment.topLeft || alignment == Alignment.topRight;
    final left =
        alignment == Alignment.topLeft || alignment == Alignment.bottomLeft;
    return Align(
      alignment: alignment,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border(
            top: top
                ? BorderSide(color: MaizeColors.tertiaryFixed, width: 4)
                : BorderSide.none,
            bottom: !top
                ? BorderSide(color: MaizeColors.tertiaryFixed, width: 4)
                : BorderSide.none,
            left: left
                ? BorderSide(color: MaizeColors.tertiaryFixed, width: 4)
                : BorderSide.none,
            right: !left
                ? BorderSide(color: MaizeColors.tertiaryFixed, width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _SmallRoundButton extends StatelessWidget {
  const _SmallRoundButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: MaizeColors.surfaceContainer.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _ShutterButton extends StatelessWidget {
  const _ShutterButton({required this.onPressed, required this.isCapturing});

  final VoidCallback? onPressed;
  final bool isCapturing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Center(
          child: isCapturing
              ? const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: onPressed != null
                        ? MaizeColors.tertiaryFixed
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: onPressed != null
                          ? MaizeColors.primary
                          : Colors.grey.shade600,
                      width: 4,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
