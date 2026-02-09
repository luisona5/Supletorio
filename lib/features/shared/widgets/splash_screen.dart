import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Splash Screen mejorada con más dinamismo y efectos visuales
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _particleAnimation;
  late Animation<Color?> _backgroundColorAnimation;

  final List<Offset> _particles = [];

  @override
  void initState() {
    super.initState();
    
    // Inicializar partículas en posiciones aleatorias
    _generateParticles();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Animación de fade para el logo
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    // Animación de escala para el logo
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    // Animación de rotación
    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * 3.14159).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    // Animación de fade para el texto (retrasada)
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeIn),
      ),
    );

    // Animación para partículas
    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Animación de color de fondo
    _backgroundColorAnimation = ColorTween(
      begin: AppTheme.primary.withOpacity(0.5),
      end: AppTheme.primary,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
  }

  void _generateParticles() {
    _particles.clear();
    for (int i = 0; i < 15; i++) {
      _particles.add(Offset(
        (0.2 + 0.6 * i / 15) * 1.0, // Valores entre 0.2 y 0.8
        (0.2 + 0.6 * i / 15) * 1.0,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _backgroundColorAnimation.value!,
                  _backgroundColorAnimation.value!.withOpacity(0.9),
                  _backgroundColorAnimation.value!.withOpacity(0.8),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Partículas de fondo animadas
                for (int i = 0; i < _particles.length; i++)
                  Positioned(
                    left: _particles[i].dx * screenSize.width +
                        sin(_particleAnimation.value * 3.14159 * 2 + i) * 20,
                    top: _particles[i].dy * screenSize.height +
                        cos(_particleAnimation.value * 3.14159 * 2 + i) * 20,
                    child: Opacity(
                      opacity: 0.3 * (0.5 + 0.5 * sin(_particleAnimation.value * 3.14159 + i)),
                      child: Container(
                        width: 4 + 2 * sin(_particleAnimation.value * 3.14159 + i),
                        height: 4 + 2 * sin(_particleAnimation.value * 3.14159 + i),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                
                // Contenido principal
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo animado con múltiples efectos
                      Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white,
                                    Colors.white.withOpacity(0.8),
                                  ],
                                  stops: [0.5, 1.0],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                    offset: const Offset(0, 10),
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.2),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                    offset: const Offset(0, -5),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Efecto de brillo interior
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: RadialGradient(
                                          colors: [
                                            Colors.white.withOpacity(0.5),
                                            Colors.transparent,
                                          ],
                                          stops: [0.1, 0.8],
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  
                                  // Icono principal
                                  Center(
                                    child: Icon(
                                      Icons.report_problem,
                                      size: 70,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                  
                                  // Anillo exterior animado
                                  Transform.scale(
                                    scale: 1.1 + 0.1 * sin (_controller.value * 3.14159 * 2),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.5),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Título con efecto de desvanecimiento y escalado
                      FadeTransition(
                        opacity: _textFadeAnimation,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - _textFadeAnimation.value)),
                          child: ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                colors: [
                                  Colors.white,
                                  Colors.white.withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds);
                            },
                            child: const Text(
                              'VeciAvisa',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.8,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10,
                                    color: Colors.black45,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Subtítulo con efecto de desvanecimiento
                      FadeTransition(
                        opacity: _textFadeAnimation,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - _textFadeAnimation.value)),
                          child: Text(
                            'Municipio de Quito',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white.withOpacity(0.9),
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w300,
                              shadows: [
                                Shadow(
                                  blurRadius: 5,
                                  color: Colors.black45,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 60),

                      // Loading indicator mejorado
                      FadeTransition(
                        opacity: _textFadeAnimation,
                        child: Container(
                          width: 100,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return Container(
                                width: 100 * (_controller.value % 0.5) * 2,
                                height: 4,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Colors.white.withOpacity(0.7),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.5),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Texto de carga
                      FadeTransition(
                        opacity: _textFadeAnimation,
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            final loadingTexts = ['Cargando', 'Cargando.', 'Cargando..', 'Cargando...'];
                            final index = (_controller.value * 4).floor() % loadingTexts.length;
                            
                            return Text(
                              loadingTexts[index],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7),
                                fontStyle: FontStyle.italic,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Olas decorativas en la parte inferior
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Transform.translate(
                    offset: Offset(0, 30 * sin(_controller.value * 3.14159 * 2)),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      child: CustomPaint(
                        painter: _WavePainter(
                          waveHeight: 20,
                          waveLength: screenSize.width / 1.5,
                          animationValue: _controller.value,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Pintor para las olas decorativas
class _WavePainter extends CustomPainter {
  final double waveHeight;
  final double waveLength;
  final double animationValue;

  _WavePainter({
    required this.waveHeight,
    required this.waveLength,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    for (double i = 0; i <= size.width; i++) {
      final x = i;
      final y = size.height - 
          waveHeight * 
          sin((x / waveLength) * 2 * 3.14159 + animationValue * 2 * 3.14159);
      
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}