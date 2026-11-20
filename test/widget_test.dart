import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_wear_app/presentation/widgets/wear/wear_success_animation.dart';

void main() {
  testWidgets('WearSuccessAnimation renders correctly on Wear OS',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WearSuccessAnimation(
            roomNumber: 204,
            title: '¡Tarea Completada!',
          ),
        ),
      ),
    );

    // Permitir animación
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('¡Tarea Completada!'), findsOneWidget);
    expect(find.text('Habitación 204'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });
}
