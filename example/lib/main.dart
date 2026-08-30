import 'package:flutter/material.dart';
import 'package:responsive_zoom/responsive_zoom.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ResponsiveZoom(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: .fromSeed(seedColor: Colors.deepPurple),
        ),
        home: LayoutBuilder(
          builder: (context, constraints) => ResponsiveZoomTestPage(),
        ),
      ),
    );
  }
}

class ResponsiveZoomTestPage extends StatelessWidget {
  const ResponsiveZoomTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final realSize = ResponsiveZoom.realScreenSize;
    final zoom = ResponsiveZoom.zoom;

    final zoomedSize = Size(realSize.width / zoom, realSize.height / zoom);

    const boxSize = Size(120, 80);

    final zoomedBoxSize = Size(boxSize.width * zoom, boxSize.height * zoom);

    final isLandscape = realSize.width > realSize.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Responsive Zoom',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF17202A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _InfoCard(
              title: 'Screen Information',
              icon: Icons.phone_android_rounded,
              children: [
                _InfoRow(
                  label: 'Real screen size',
                  value:
                      '${realSize.width.toStringAsFixed(1)} × '
                      '${realSize.height.toStringAsFixed(1)}',
                ),
                _InfoRow(
                  label: 'Zoom',
                  value: '${zoom.toStringAsFixed(3)}x',
                  valueColor: Colors.blue,
                ),
                _InfoRow(
                  label: 'Zoomed screen size',
                  value:
                      '${zoomedSize.width.toStringAsFixed(1)} × '
                      '${zoomedSize.height.toStringAsFixed(1)}',
                ),
                _InfoRow(
                  label: 'Orientation',
                  value: isLandscape ? 'Landscape' : 'Portrait',
                ),
                _InfoRow(
                  label: 'Reference size',
                  value:
                      '${ResponsiveZoom.referenceSize.width.toStringAsFixed(0)} × '
                      '${ResponsiveZoom.referenceSize.height.toStringAsFixed(0)}',
                ),
              ],
            ),

            const SizedBox(height: 20),

            _InfoCard(
              title: 'Box Dimensions',
              icon: Icons.crop_square_rounded,
              children: [
                _InfoRow(
                  label: 'Original',
                  value:
                      '${boxSize.width.toStringAsFixed(0)} × '
                      '${boxSize.height.toStringAsFixed(0)}',
                ),
                _InfoRow(
                  label: 'After zoom',
                  value:
                      '${zoomedBoxSize.width.toStringAsFixed(1)} × '
                      '${zoomedBoxSize.height.toStringAsFixed(1)}',
                  valueColor: Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 20),

            _SectionTitle(
              title: 'Visual Comparison',
              subtitle: 'Original size vs. zoomed size',
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _BoxPreview(
                    title: 'Original',
                    subtitle:
                        '${boxSize.width.toInt()} × ${boxSize.height.toInt()}',
                    width: boxSize.width,
                    height: boxSize.height,
                    color: Colors.blue,
                  ),

                  const SizedBox(height: 30),

                  const Divider(),

                  const SizedBox(height: 30),

                  _BoxPreview(
                    title: 'Zoomed',
                    subtitle:
                        '${zoomedBoxSize.width.toStringAsFixed(1)} × '
                        '${zoomedBoxSize.height.toStringAsFixed(1)}',
                    width: zoomedBoxSize.width,
                    height: zoomedBoxSize.height,
                    color: Colors.green,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _ZoomIndicator(zoom: zoom),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.15)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Rotate or resize the screen to see how the '
                      'reference size and zoom value change.',
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        height: 1.4,
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
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.blue.shade700),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: valueColor ?? const Color(0xFF17202A),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
      ],
    );
  }
}

class _BoxPreview extends StatelessWidget {
  final String title;
  final String subtitle;
  final double width;
  final double height;
  final Color color;

  const _BoxPreview({
    required this.title,
    required this.subtitle,
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.crop_square_rounded, color: color, size: 28),
        ),
      ],
    );
  }
}

class _ZoomIndicator extends StatelessWidget {
  final double zoom;

  const _ZoomIndicator({required this.zoom});

  @override
  Widget build(BuildContext context) {
    final percentage = zoom * 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade500, Colors.blue.shade500],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'CURRENT ZOOM',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${zoom.toStringAsFixed(3)}x',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${percentage.toStringAsFixed(1)}% of reference scale',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
